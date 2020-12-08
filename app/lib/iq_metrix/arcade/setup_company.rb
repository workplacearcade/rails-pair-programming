# frozen_string_literal: true

module IQMetrix
  module Arcade
    class SetupCompany
      attr_accessor :partner

      def initialize(partner)
        @partner = partner
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        entity = CreateCompany.run name: partner.business_name, account_starts_with_tokens: false, benjo_prefix: '[IQ]'
        @partner.update_attributes!(entity: entity)

        IQMetrix::Arcade::SetupHierarchy.run(partner: partner)
        IQMetrix::Arcade::AddUsers.run(partner: partner, invite_newly_added: false)
      end
    end
  end
end
