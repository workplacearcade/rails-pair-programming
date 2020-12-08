# frozen_string_literal: true

class Level < ApplicationRecord
  has_many :users, inverse_of: :level

  validates :level_number, presence: true
  validates :title, presence: true
  validates :level_start, presence: true
  validates :level_end, presence: true

  scope :level_start, ->(score) { where('levels.level_start <= ?', score) }
  scope :level_end, ->(score) { where('levels.level_end > ?', score) }

  def self.for_experience(experience)
    where('levels.level_start <= ? AND ? < levels.level_end', experience, experience).first
  end

  def percentage_through_level(user)
    ((user.experience - level_start) / (level_end - level_start) * 100).floor
  end

  def experience_to_level_up(user)
    level_end - user.experience
  end
end
