# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :entity

  has_many :team_assignments, dependent: :destroy
  has_many :users, through: :team_assignments

  has_many :kpis, foreign_key: :team_id

  has_many :integration_identifiers
  has_many :sales, foreign_key: :team_id
end
