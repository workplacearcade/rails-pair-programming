# frozen_string_literal: true

module IQMetrix
  module Errors
    class BaseError < StandardError
      def initialize(message)
        super(message)
      end
    end
    class UnknownError < BaseError; end
    class ServerError < BaseError; end
    class AuthenticationError < BaseError; end
    class ConfigurationError < BaseError; end
  end
end
