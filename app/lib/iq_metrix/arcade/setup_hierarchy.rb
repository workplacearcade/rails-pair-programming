# frozen_string_literal: true

module IQMetrix
  module Arcade
    class SetupHierarchy
      attr_accessor :partner, :entity

      def initialize(partner:, entity: nil)
        @partner = partner
        @entity = partner.entity || entity
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        teams = get_teams
        hierarchy = map_teams_to_hierarchy(teams)
        create_from_hierachy hierarchy, entity
      end

      private

      def get_teams
        IQMetrix::Commands::Locations::GetAll.run(partner: partner)
      end

      def map_teams_to_hierarchy(teams)
        region_hash = Hash.new do |top_level_hash, new_key|
          top_level_hash[new_key] = Hash.new { |h, k| h[k] = [] }
        end

        teams.each do |team|
          next unless team.disabled.zero?

          region_hash[team.region_name][team.district_name] << {
            name: team.store_name
          }
        end

        region_hash
      end

      def create_from_hierachy(hierarchy, entity)
        return create_from_hierachy hierarchy[hierarchy.keys.first], entity if hierarchy.is_a?(Hash) && hierarchy.keys.size == 1

        return create_teams_for_hierarchy(hierarchy, entity) if hierarchy.is_a? Array

        hierarchy.each do |name, children|
          new_entity = Entity.new(
            name: name
          ).save_with_conversation(with_csm: true)

          entity.add_child new_entity
          new_entity.create_audience

          create_from_hierachy(children, new_entity)
        end
      end

      def create_teams_for_hierarchy(teams_array, entity)
        teams_array.each do |team|
          AddTeamToEntity.run(
            name: team[:name],
            entity: entity,
            has_leagues: false,
            company_identifier: team[:name],
            with_csm_in_conversation: true
          )
        end
      end
    end
  end
end
