# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Reports
      class SalesByEmployee
        attr_accessor :partner

        def initialize(_partner: nil)
          @partner = IQMetrix::Partner.first
        end

        def self.run(*args)
          new(*args).call
        end

        def call
          Typhoeus.get('https://dataconnect.iqmetrix.net/reports/SalesByEmployeeReport',
                       headers: {
                         Authorization: ,# Do nothing,
                         Accept: 'application/JSON',
                         'Content-Type' => 'application/JSON'
                       },
                       params: {
                         'StartDate' => 1.day.ago,
                         'StopDate' => 1.day.from_now,
                         'CompanyID' => partner.company_id
                       }).response_body
        end
      end
    end
  end
end
