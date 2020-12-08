# frozen_string_literal: true

module IQMetrix
  module Commands
    module Locations
      class GetAll
        attr_accessor :partner

        def initialize(partner:)
          @partner = partner
        end

        def self.run(*args)
          new(*args).call
        end

        def call
          payload = IQMetrix::Requests::Locations::MasterList.run(partner: partner)
          map_payload_to_locations payload
        end

        private

        def map_payload_to_locations(payload)
          payload.map do |location_json|
            IQMetrix::Location.from_json(location_json)
          end
        end
      end
    end
  end
end
