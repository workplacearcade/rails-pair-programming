# frozen_string_literal: true

class IntegrationIdentifier < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :team, required: false
  belongs_to :entity, required: false

  def self.find_by_identifier(identifier)
    where('lower(identifier) = ?', identifier.strip.downcase).first
  end

  def self.invalid
    where(user_id: nil, team_id: nil, entity_id: nil, conversation_id: nil, kpi_group_id: nil, audience_id: nil)
  end

  def self.with_deleted_user
    where.not(user_id: nil).where.not(user_id: User.all.pluck(:id))
  end
end
