# frozen_string_literal: true

module IQMetrix
  module Arcade
    class RetrieveBIReports
      include EmailIntegration

      def self.run(*args)
        new(*args).call
      end

      def call
        return unless (unread_email = first_unread_message)

        partner, file = strip_attachment_and_partner_info unread_email

        return if partner.cancelled_at.present?

        process_sheets partner, file
        unread_email.label('Integration Processed')
      rescue StandardError => e
        Rollbar.error(e)
        unread_email.label('Errored') if unread_email.present?
      end

      private

      def gmail
        @gmail ||= Gmail.connect(
          Rails.application.credentials.iqmetrix_gmail_username,
          Rails.application.credentials.iqmetrix_gmail_password
        )
      end

      # The find check is to ensure we ignore performance group reports
      def first_unread_message
        gmail.inbox.find(:unread).find do |email|
          email.to[0].mailbox.exclude? 'performance_group'
        end
      end

      def strip_attachment_and_partner_info(email)
        email.read!

        to = email.to[0]

        return unless (partner = find_corresponding_partner(to.mailbox))

        return unless (attachment = strip_file(email, file_extension: 'xls'))

        [partner, StringIO.new(attachment[0])]
      end

      # Mailbox is in the form of iqmetrix_data+<company_id>
      def find_corresponding_partner(recipient_mailbox)
        _, company_id = recipient_mailbox.split('+')

        return if company_id.blank?

        IQMetrix::Partner.find_by company_id: company_id
      end

      def process_sheets(partner, file)
        IQMetrix::Arcade::ProcessBIReports.run(
          partner: partner,
          file: file
        )
      end
    end
  end
end
