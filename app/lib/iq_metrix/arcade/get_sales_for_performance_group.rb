# frozen_string_literal: true

module IQMetrix
  module Arcade
    class GetSalesForPerformanceGroup
      attr_accessor :performance_group, :kpi_group, :from, :to, :employee_ids, :backdate

      def initialize(performance_group:, from: 15.minutes.ago, to: Time.zone.now, employee_ids: nil, backdate: false)
        @performance_group = performance_group
        @kpi_group = performance_group.kpi_group
        @from = from
        @to = to
        @employee_ids = employee_ids
        @backdate = backdate
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        create_sales get_sales
      end

      private

      def create_sales(sales)
        sales.each do |sale_json|
          product = IQMetrix::Product.from_json(sale_json)

          unique_id = "#{kpi_group.id}-#{product.raw_data[:sale_invoice_product_row_id]}"

          next if existing_sale_ids_hash.key? unique_id

          @existing_sale_ids_hash[unique_id] = true

          next unless (user = find_user_for_sale(product))

          next unless (kpi = user.kpis.where(kpi_group: kpi_group).first)

          Sale.create(
            user: user,
            kpi: kpi,
            quantity: product.raw_data[performance_group.quantity_attribute.to_sym],
            raw_data: product.raw_data,
            created_at: product.parsed_created_at,
            description: unique_id,
            entity: entity,
            source: :integration
          )
        end
      end

      def get_sales
        performance_group.query_sales(start_time: from.to_time, end_time: to.to_time, employee_ids: employee_ids)
      end

      def find_user_for_sale(sale)
        integration_identifier_mapping[sale.integration_identifier.to_s]
      end

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

        IntegrationIdentifier.joins(:user).where(user: entity.all_users).each do |integration_identifier|
          @integration_identifier_mapping[integration_identifier.identifier.to_s] = integration_identifier.user
        end

        @integration_identifier_mapping
      end

      def entity
        @entity ||= performance_group.iq_metrix_partner.entity
      end
    end
  end
end
