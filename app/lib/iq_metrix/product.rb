# frozen_string_literal: true

### Class for wrapping the product JSON structure returned by IQMetrix. This is not backed by a DB table

module IQMetrix
  class Product
    include ResponseObject

    def sku
      payload[:product_identifier]
    end

    def integration_identifier
      payload[:employee_id]
    end

    def store_name
      payload[:invoiced_at]
    end

    def parsed_created_at
      return Time.zone.now if payload[:date_created_utc].nil?

      ActiveSupport::TimeZone['UTC'].parse(payload[:date_created_utc])
    end

    def raw_data
      payload.merge(
        sku: sku,
        integration_identifier: integration_identifier
      )
    end
  end
end
