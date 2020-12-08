# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Products
      class DetailsReport < IQMetrix::Requests::Base
        attr_accessor :partner, :start_date, :stop_date

        def initialize(partner:, start_date: 1.day.ago, stop_date: Time.zone.now)
          @partner = partner
          @start_date = start_date
          @stop_date = stop_date
        end

        def self.run(*args)
          new(*args).call
        end

        REPORT_TYPES = {
          default: 1,
          tax_detail: 2,
          tax_column: 3,
        }.freeze

        SEARCH_METHODS = {
          sku: 1,
          manufacturer: 2,
          category: 3,
          invoice: 4,
          customer_id: 5,
          serial_number: 6
        }.freeze

        def call
          authenticated_web_request(
            url: "#{partner.endpoint}/partner/reports/productdetailreport",
            method: :get,
            params: {
              'CompanyID' => partner.company_id,
              'StartDate' => start_date.strftime('%FT%T'),
              'StopDate' => stop_date.strftime('%FT%T'),
              'ReportPart' => REPORT_TYPES[:default],
              'SearchMethod' => SEARCH_METHODS[:category],
              'CategoryNumber' => 10,
            }
          )
        end
      end
    end
  end
end
