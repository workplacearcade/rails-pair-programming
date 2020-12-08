# frozen_string_literal: true

class Kpi < ApplicationRecord
  has_many :user_targets, dependent: :destroy
  has_many :users, through: :user_targets
  has_many :sales, inverse_of: :kpi

  belongs_to :kpi_group
  belongs_to :team, required: false

  validates :title, presence: true

  def name
    title
  end
end
