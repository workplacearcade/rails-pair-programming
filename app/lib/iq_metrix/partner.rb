# frozen_string_literal: true

module IQMetrix
  class Partner < ApplicationRecord
    self.table_name = 'iq_metrix_partners'

    belongs_to :entity
    has_many :iq_metrix_performance_groups, class_name: 'IQMetrix::PerformanceGroup'

    scope :active, -> { where(cancelled_at: nil) }

    def self.sanitize_payload(payload)
      {
        company_id: payload['CompanyID'],
        name: payload['CompanyName'],
        business_name: payload['DoingBusinessAs'],
        endpoint: payload['PreferredEndpoint']
      }
    end
  end
end
