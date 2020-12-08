# frozen_string_literal: true

module IQMetrix
  class << self
    attr_accessor :configuration
  end

  LOGGER = Rails.logger

  def self.configure
    self.configuration ||= Configuration.new
    LOGGER.tagged("IQMETRIX") {
      yield configuration
    }

    raise IQMetrix::Errors::ConfigurationError unless configuration.valid?

    self.configuration
  end
end
