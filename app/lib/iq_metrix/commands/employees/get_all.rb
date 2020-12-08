# frozen_string_literal: true

module IQMetrix
  module Commands
    module Employees
      class GetAll
        attr_accessor :partner

        def initialize(partner:)
          @partner = partner
        end

        def self.run(*args)
          new(*args).call
        end

        def call
          payload = IQMetrix::Requests::Employees::MasterList.run(partner: partner)
          map_payload_to_employees payload
        end

        private

        def map_payload_to_employees(payload)
          payload.map do |employee_json|
            IQMetrix::Employee.from_json(employee_json)
          end
        end
      end
    end
  end
end
