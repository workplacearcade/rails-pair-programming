# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Employees
      class MasterList < IQMetrix::Requests::Base
        attr_accessor :partner

        def initialize(partner:)
          @partner = partner
        end

        def self.run(*args)
          new(*args).call
        end

        MASTER_LIST_STATUSES = {
          disabled: 0,
          enabled: 1,
          any: 2,
        }.freeze

        def call
          authenticated_web_request(
            url: "#{partner.endpoint}/partner/reports/employeemasterlistreport",
            method: :get,
            params: {
              'CompanyID' => partner.company_id,
              'EnabledStatus' => MASTER_LIST_STATUSES[:any]
            }
          )
        end
      end
    end
  end
end
