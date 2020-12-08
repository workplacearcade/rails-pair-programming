# frozen_string_literal: true

module IQMetrix
  module Arcade
    class AddUsers
      attr_accessor :partner, :entity, :report_mode, :add_teams, :allow_updates, :invite_newly_added

      def initialize(partner:, entity: nil, report_mode: false, add_teams: true, allow_updates: false, invite_newly_added: false)
        @partner = partner
        @entity = partner.entity || entity
        @report_mode = report_mode
        @add_teams = add_teams
        @allow_updates = allow_updates
        @invite_newly_added = invite_newly_added
      end

      def self.run(*args)
        new(*args).call
      end

      def call
        return if partner.integration_settings['ad_disabled']

        employees = get_employees_from_iq
        formatted_employees = format_employees(employees)
        update_account formatted_employees
      end

      private

      def get_employees_from_iq
        IQMetrix::Commands::Employees::GetAll.run(partner: partner)
      end

      def format_employees(employees)
        formatted_employees = {}

        employees.each do |employee|
          firstname, lastname = employee.employee_name.split(' ')
          status = if employee.disabled == 'No' && employee.locked == 'No'
                     'active'
                   else
                     'locked'
                   end

          next unless (email = get_email_address(employee))

          if formatted_employees[email].present?
            current_ids = formatted_employees[email][:integration_identifiers]
            current_ids |= [employee.username, employee.employee_id]
            formatted_employees[email][:integration_identifiers] = current_ids
            next
          end

          formatted_employees[email] = {
            uid: employee.username,
            firstname: firstname,
            lastname: lastname,
            email: email,
            status: status,
            integration_identifiers: [employee.username, employee.employee_id, employee.employee_name],
            integration_source: 'iqmetrix',
            team_uid: employee.primary_location,
          }
        end

        formatted_employees
      end

      def update_account(formatted_employees)
        Account::UpdateUsers.run(
          entity: entity,
          user_objects: formatted_employees.values,
          report_mode: report_mode,
          add_teams: add_teams,
          allow_updates: allow_updates,
          invite_newly_added: invite_newly_added
        )
      end

      def get_email_address(employee)
        return employee.email_address unless (email_attribute = partner.integration_settings['email_attribute'])

        employee.send(email_attribute)
      end
    end
  end
end
