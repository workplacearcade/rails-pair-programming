# frozen_string_literal: true

require 'spreadsheet'

module IQMetrix
  module Arcade
    class ProcessBIReports
      include CSVIntegration

      USERNAME_COLUMN = 0
      # We don't do anything with this but CSVIntegration requires it
      TEAM_COLUMN = 0

      attr_accessor :partner, :file, :metric_mapping

      def initialize(partner:, file:)
        @partner = partner
        @file = file
        @metric_mapping = {}
        @logger = IntegrationReporter.new(reportable_name: entity.name, entity_id: entity.id)
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        get_row_index_by_kpi_group_identifier header_row
        create_new_metrics_from_metric_map
        process_sheet
        logger.report
      end

      SKIP_COUNT = 2

      def process_sheet
        report.rows.each.with_index do |row, index|
          next if index <= SKIP_COUNT

          process_row(row)
        end
      end

      def process_row(row)
        @row = row

        # We skip blank rows
        unless (user_identifier = row[self.class::USERNAME_COLUMN])
          return nil
        end

        unless (user = identify_user(user_identifier))
          logger.error(key: :missing_user, payload: { user_id: user_identifier, data: row.to_s })
          return nil
        end

        logger.warning(key: :missing_team, payload: { team_id: row[self.class::TEAM_COLUMN], user_id: user.id, data: row.to_s }) unless (team = identify_team(row[self.class::TEAM_COLUMN], user))

        kpis_to_process.each do |kpi_object|
          next unless (parsed_amount = calculate_parsed_amount(kpi_object, row))

          create_sale kpi_object[:title], user, team, parsed_amount
        end
      end

      HEADER_ROW_INDEX = 2

      # Returns a hash that maps each KPI group identifier to its corresponding row
      def get_row_index_by_kpi_group_identifier(header_row)
        index = 0

        header_row.each do |value|
          metric_mapping[value] = index unless value == 'Employee Name'

          index += 1
        end
      end

      # Goes through the created metric map and creates any new metrics as required
      def create_new_metrics_from_metric_map
        metric_mapping.each do |identifier, _|
          next if entity.kpi_groups.find_by(company_identifier: identifier).present?

          @group = KpiGroup.create_with_children!(
            entity: entity,
            title: sanitized_metric_title(identifier),
            verb: 'Sold',
            source: 'integration',
            assign: 'everyone',
            company_identifier: identifier
          )
        end
      end

      private

      # BI generated reports contain all three sheets (different groupings) whereas manually sent ones only include one sheet
      def report
        @report ||= Spreadsheet.open(file).worksheet(2) || Spreadsheet.open(file).worksheet(0)
      end

      def entity
        @entity ||= partner.entity
      end

      def header_row
        report.rows[HEADER_ROW_INDEX]
      end

      # Titles come in the form of (Q/NP) Metric Name
      def sanitized_metric_title(raw_title)
        raw_title.gsub(/\((NP|Q)\)/, '').strip
      end

      # This logic is overriding concepts outlined in the CSVIntegration module
      def kpis_to_process
        metric_mapping.map do |identifier, column|
          { title: identifier, column: column }
        end
      end

      def identify_user(identifier)
        return if identifier.blank?

        IntegrationIdentifier.find_by(identifier: identifier).try(:user)
      end

      def identify_kpi(identifier, user, team)
        return unless (kg = KpiGroup.find_by(company_identifier: identifier, entity: entity))

        unless (kpi = user.kpis.where(kpi_group: kg).first) || (team.present? && (kpi = team.kpis.where(kpi_group: kg).first))
          *_, kpi = KpiGroup::AddUser.run(kpi_group: kg, user: user)
          logger.warning(key: :missing_metric, payload: { kpi_group_id: kg.id, user_id: user.id, data: row.to_s })
        end

        kpi
      end

      attr_reader :logger

      def sale_created_at(_process_date)
        1.day.ago.midday
      end
    end
  end
end
