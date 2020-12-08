# frozen_string_literal: true

class Entity < ApplicationRecord
  has_closure_tree

  has_many :teams
  has_many :users

  
  def all_users
    User.where('users.entity_id in (?)', self_and_descendant_ids)
  end

  def all_users_without_csm
    all_users.where.not(id: csm_user)
  end

  def sales
    Sale.joins(:kpi).joins(
      'LEFT JOIN kpi_groups on kpi_group_id = kpi_groups.id'
    ).where('kpi_groups.entity_id in (?)', self_and_descendants.pluck(:id))
  end

  def kpi_groups
    KpiGroup.where('entity_id in (?)', self_and_descendants.pluck(:id))
            .order(:title)
  end
end
