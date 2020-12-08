# frozen_string_literal: true

class KpiGroup < ApplicationRecord
  has_many :kpis, dependent: :destroy

  belongs_to :entity

  validates_inclusion_of :source, in: %w[manual integration aila], allow_nil: false
  validates_inclusion_of :ranking_direction, in: ['DESC', 'ASC'], allow_nil: false

  def self.find_by_name(name)
    KpiGroup.where("(kpi_groups.title || ' ' || kpi_groups.verb) ILIKE ?", name).first
  end

  def name
    "#{title} #{verb}"
  end

  def sales
    return Sale.joins(:kpi).where('kpis.kpi_group_id = ?', id) if sales_query.nil?

    query_sales
  end

  def user_targets
    UserTarget.joins(:kpi).where('kpis.kpi_group_id = ?', id).active
  end

  def assigned_users
    User.where(id: user_targets.pluck(:user_id))
  end
end
