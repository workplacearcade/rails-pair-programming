# frozen_string_literal: true

module IQMetrix
  class Configuration
    # Account username
    attr_accessor :username

    # Account password
    attr_accessor :password

    # Partner Username
    attr_accessor :partner_id

    # Client ID and Secret for OAuth Flow
    attr_accessor :client_id, :client_secret

    def initialize
      @username = nil
      @password = nil
      @partner_id = nil
      @client_id = nil
      @client_secret = nil
    end

    REQUIRED_CONFIGURATION_VALUES = [:username, :password, :partner_id].freeze

    def valid?
      REQUIRED_CONFIGURATION_VALUES.none? { |attribute| send(attribute).nil? }
    end

    def expect_values!(values)
      raise IQMetrix::Errors::ConfigurationError if values.select do |attribute|
        send(attribute).nil?
      end.any?
    end
  end
end
