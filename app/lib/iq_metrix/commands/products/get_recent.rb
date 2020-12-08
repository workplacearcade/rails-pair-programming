# frozen_string_literal: true

module IQMetrix
  module Commands
    module Products
      class GetRecent
        attr_accessor :partner, :from, :to

        def initialize(partner:, from: 15.minutes.ago, to: Time.zone.now)
          @partner = partner
          @from = from
          @to = to
        end

        def self.run(*args)
          new(*args).call
        end

        def call
          payload = IQMetrix::Requests::Products::DetailsReport.run(partner: partner, start_date: from, stop_date: to)
          map_payload_to_products payload
        end

        private

        def map_payload_to_products(payload)
          payload.map do |product_json|
            IQMetrix::Product.from_json(product_json)
          end
        end
      end
    end
  end
end
