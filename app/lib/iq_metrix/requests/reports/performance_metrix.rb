# frozen_string_literal: true

require 'typhoeus'

module IQMetrix
  module Requests
    module Reports
      class PerformanceMetrix
        def initialize(_partner: nil)
          @partner = IQMetrix::Partner.first
        end

        def self.run(*args)
          new(*args).call
        end

        def call
          # Do nothing
        end
      end
    end
  end
end
