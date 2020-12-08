# frozen_string_literal: true

module IQMetrix
  module Arcade
    class ImportSales
      attr_accessor :partner, :entity, :from, :to

      def initialize(partner:, from: Time.zone.now.beginning_of_day, to: Time.zone.now.end_of_day)
        @partner = partner
        @entity = partner.entity
        @from = from.in_time_zone(entity.time_zone)
        @to = to.in_time_zone(entity.time_zone)
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        return if partner.integration_settings['sales_disabled']

        import_sales IQMetrix::Commands::Products::GetRecent.run(partner: partner, from: from, to: to)
        check_game_progress
      end

      def import_sales(sales)
        sales = sales.map do |sale|
          next if existing_sale_ids_hash.key? sale.raw_data[:sale_invoice_product_row_id]

          @existing_sale_ids_hash[sale.raw_data[:sale_invoice_product_row_id]] = true

          Sale.new(
            user_id: find_user_id_for_sale(sale),
            quantity: sale.quantity,
            raw_data: sale.raw_data,
            created_at: sale.parsed_created_at,
            description: sale.raw_data[:sale_invoice_product_row_id],
            entity: entity,
            source: :integration
          )
        end.compact

        Sale.import!(sales, batch_size: 1000) if sales.any?
      end

      def check_game_progress
        Campaign.active.where(user: entity.all_users).each do |campaign|
          campaign.quests.each do |quest|
            # Campaign::CheckRPARewards.run(competition_quest: quest, amount_verified: quantity) if ['rpa_one_time', 'rpa_every_time'].include? campaign.type

            quest.check_completion
          end
        end
      end

      private

      def find_user_id_for_sale(sale)
        integration_identifier_mapping[sale.integration_identifier.to_s]
      end

      TIME_BUFFER = 10.minutes

      def existing_sale_ids_hash
        return @existing_sale_ids_hash if @existing_sale_ids_hash.present?

        @existing_sale_ids_hash = {}

        Sale.where(entity: entity).pluck(:description).each do |description|
          @existing_sale_ids_hash[description] = true
        end

        @existing_sale_ids_hash
      end

      def integration_identifier_mapping
        return @integration_identifier_mapping unless @integration_identifier_mapping.nil?

        @integration_identifier_mapping = {}

        IntegrationIdentifier.where(user: entity.all_users).each do |integration_identifier|
          @integration_identifier_mapping[integration_identifier.identifier] = integration_identifier.user_id
        end

        @integration_identifier_mapping
      end
    end
  end
end
