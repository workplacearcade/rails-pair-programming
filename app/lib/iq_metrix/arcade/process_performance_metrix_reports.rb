# frozen_string_literal: true

require 'spreadsheet'

module IQMetrix
  module Arcade
    class ProcessPerformanceMetrixReports
      include CSVIntegration

      USERNAME_COLUMN = 0
      # We don't do anything with this but CSVIntegration requires it
      TEAM_COLUMN = 0

      attr_accessor :partner, :entity, :file

      def initialize(partner:, file:)
        @partner = partner
        @entity = partner.entity
        @file = file
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        return unless (metric_titles = get_metric_titles_from_report)

        metric_mapping = construct_metric_queries_for metric_titles

        apply_queries_to_metrics metric_mapping
      end

      private

      def get_metric_titles_from_report
        report.worksheets.map(&:name)
      end

      def apply_queries_to_metrics(metric_mapping)
        metric_mapping.each do |metric_name, sales_query|
          kpi_group = KpiGroup.find_or_create_by(entity: entity, company_identifier: metric_name)

          kpi_group.title = metric_name
          kpi_group.unit = '#'
          kpi_group.verb = 'Sold'
          kpi_group.source = 'integration'
          kpi_group.assign = 'everyone'
          kpi_group.save

          KpiGroup::Assign.run(kpi_group: kpi_group)

          IQMetrix::PerformanceGroup.create(
            name: kpi_group.name,
            sales_query: sales_query,
            quantity_attribute: 'quantity', # this may be changed after creation
            iq_metrix_partner: partner,
            kpi_group: kpi_group
          )
        end
      end

      def construct_metric_queries_for(metric_titles)
        metric_titles.map.with_index do |metric_name, index|
          corresponding_sheet = report.worksheet(index)

          # If we are unable to determine composition type then we are looking at an invalid sheet
          next unless (composition_type = determine_metric_composition_type(corresponding_sheet))

          composition_hash = extract_composition_information_from(corresponding_sheet)

          [metric_name, query_for(composition_type, composition_hash)]
        end
      end

      def query_for(composition_type, composition_hash)
        if composition_type == 'Products'
          query = { 'ProductIdentifier' => { '$in' => composition_hash[:included_skus].uniq } }
        elsif composition_type == 'Categories'
          query = {}
          query.deep_merge!('ProductIdentifier' => { '$nin' => composition_hash[:excluded_skus].uniq }) if composition_hash[:excluded_skus]&.any?
          categories = composition_hash[:categories]
                       .uniq
                       .map { |c| ">>\\ #{Regexp.escape(c)}($|\\ >>)" }
                       .join('|')
          query.deep_merge!('CategoryPath' => { '$regex' => categories })
        end

        query
      end

      def determine_metric_composition_type(sheet)
        return if sheet.rows.first.nil?

        composition_column = sheet.rows.first[0]

        return unless composition_column.present? && composition_column.include?('Performance Group Setup')

        composition_column.gsub('Performance Group Setup : ', '').strip
      end

      ROW_SKIP_COUNT = 3 # The first three rows include header information

      def extract_composition_information_from(sheet)
        composition_hash = {
          included_skus: [],
          excluded_skus: [],
          categories: []
        }

        sheet.rows.each.with_index do |row, index|
          next if index < ROW_SKIP_COUNT
          next if row[0].nil?

          # Rows can be one of three formats:
          key = case row[0..2].select(&:nil?).size
                # 1. A row includes SKU, Product name and inclusion information
                when 0
                  if row[2] == 'Yes'
                    :included_skus
                  else
                    :excluded_skus
                  end
                # 2. A row just includes SKU and Product Name
                when 1
                  :included_skus
                # 3. The row includes a single element which is inferred to be a category name
                when 2
                  :categories
                end

          composition_hash[key] << row[0].strip
        end

        composition_hash
      end

      def report
        @report ||= Spreadsheet.open(file)
      end
    end
  end
end
