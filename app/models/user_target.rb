# frozen_string_literal: true

class UserTarget < ApplicationRecord
  belongs_to :user
  belongs_to :kpi
  belongs_to :team, required: false

  scope :for_kpi, ->(kpi_id) { where(kpi_id: kpi_id) }
  scope :for_team, ->(team_id) { where(team_id: team_id) }

  def self.for_kpi_title(title)
    where(kpi: Kpi.where(title: title))
  end

  def self.active
    where(
      '(starts_at IS NULL OR starts_at <= ?) AND (ends_at IS NULL OR ends_at >= ?)', Time.zone.now, Time.zone.now
    ).joins(:user)
      .where(users: { locked_at: nil })
  end

  def sales
    Sale.where(kpi: kpi, user: user)
  end
end
