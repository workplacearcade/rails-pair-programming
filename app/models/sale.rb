# frozen_string_literal: true

class Sale < ApplicationRecord
  belongs_to :kpi
  belongs_to :user
  belongs_to :team, required: false
  belongs_to :entity, required: false

  validates :quantity, presence: true, numericality: true
  validates_inclusion_of :source, in: ['user_created', 'integration', 'manager_created', 'scanned', 'csm_created', 'iqmetrix'], allow_nil: true

  scope :for_user, ->(user) { where('sales.user_id=?', user) }
  scope :for_team, ->(team) { where('sales.team_id=?', team) }
  scope :for_kpi, ->(kpi) { where('sales.kpi_id in (?)', kpi) }
end
