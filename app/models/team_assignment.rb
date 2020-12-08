# frozen_string_literal: true

class TeamAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates_inclusion_of :assignment_type, in: ['primary', 'secondary']

  scope :active, -> { where(assignment_type: :primary) }

  def active?
    assignment_type.to_sym == :primary
  end
end
