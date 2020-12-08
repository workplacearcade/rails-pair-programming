# frozen_string_literal: true

class User < ApplicationRecord
  after_create :set_level
  
  belongs_to :entity
  belongs_to :level, required: false

  has_many :team_assignments, dependent: :destroy
  has_many :teams, through: :team_assignments
  has_many :active_teams, -> { where(team_assignments: { assignment_type: :primary }) }, class_name: 'Team', through: :team_assignments, source: 'team'
  has_many :secondary_teams, -> { where(team_assignments: { assignment_type: :secondary }) }, class_name: 'Team', through: :team_assignments, source: 'team'

  has_many :sales
  
  has_many :user_targets, dependent: :destroy
  has_many :kpis, through: :user_targets

  scope :active, -> { where(locked_at: nil) }
  
  # While this does have the potential to return multiple people
  # We are making the assumption that its usage would be similar to any other
  # find_by method
  def self.find_by_name(name)
    User.where("(users.firstname || ' ' || users.lastname) ILIKE ?", name).first
  end

  def team
    teams.where(team_assignments: { assignment_type: :primary }).first
  end

  def fullname
    fullname = [firstname, lastname].compact.join(' ')
    fullname = email if fullname.blank?
    fullname
  end

  def name
    fullname
  end

  def set_level
    self.level = Level.find_by(level_number: 1) || Level.first
    save
  end
end
