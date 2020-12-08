# frozen_string_literal: true

module IQMetrix
  module Commands
    module Partners
      class UpdateList
        def self.run(*args)
          new(*args).call
        end

        def call
          payload = get_partner_list
          update_persisted_partners payload
        end

        private

        def get_partner_list
          IQMetrix::Requests::Partners::GetRelationships.run
        end

        def update_persisted_partners(payload)
          payload.each do |object|
            partner = IQMetrix::Partner.find_or_create_by(company_id: object['CompanyID'])

            partner.update!(IQMetrix::Partner.sanitize_payload(object))
          end
        end
      end
    end
  end
end
