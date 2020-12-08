# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Authentication
      class GetToken < IQMetrix::Requests::Base
        def self.run(*args)
          new(*args).call
        end

        def call
          IQMetrix.configuration.expect_values!([:client_id, :client_secret])

          headerless_web_request(
            url: 'https://accounts.iqmetrix.net/v1/oauth2/token',
            method: :post,
            body: {
              grant_type: 'password',
              username: IQMetrix.configuration.username,
              password: IQMetrix.configuration.password,
              client_id: IQMetrix.configuration.client_id,
              client_secret: IQMetrix.configuration.client_secret,
            }
          )['access_token']
        end
      end
    end
  end
end
