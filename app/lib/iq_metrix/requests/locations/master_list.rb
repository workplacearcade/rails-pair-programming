# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Locations
      class MasterList < IQMetrix::Requests::Base
        attr_accessor :partner

        def initialize(partner:)
          @partner = partner
        end

        def self.run(*args)
          new(*args).call
        end

        def call
          authenticated_web_request(
            method: :get,
            url: "#{partner.endpoint}/partner/reports/locationmasterlistreport",
            params: {
              'CompanyID' => partner.company_id,
            }
          )
        end
      end
    end
  end
end
