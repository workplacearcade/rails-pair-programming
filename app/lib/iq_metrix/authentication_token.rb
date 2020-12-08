# frozen_string_literal: true

# rubocop:disable Style/GlobalVars
module IQMetrix
  class AuthenticationToken
    TOKEN_KEY_NAME = 'iq_metrix_token'

    def self.get
      $redis.get(TOKEN_KEY_NAME) || refresh_token
    end

    def self.refresh_token
      token = IQMetrix::Requests::Authentication::GetToken.run
      $redis.set(TOKEN_KEY_NAME, token)
      token
    end
  end
end

# rubocop:enable Style/GlobalVars
