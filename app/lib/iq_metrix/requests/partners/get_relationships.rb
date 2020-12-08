# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Partners
      class GetRelationships < IQMetrix::Requests::Base
        def self.run(*args)
          new(*args).call
        end

        def call
          authenticated_web_request(
            url: 'https://dataconnect.iqmetrix.net/partner/relationships',
            method: :get
          )
        end
      end
    end
  end
end
