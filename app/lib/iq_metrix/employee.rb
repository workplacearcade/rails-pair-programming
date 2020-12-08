# frozen_string_literal: true

### Class for wrapping the employee JSON structure returned by IQMetrix. This is not backed by a DB table

module IQMetrix
  class Employee
    include ResponseObject

    def assigned_locations
      payload[:assigned_locations].split(',').map(&:strip)
    end
  end
end
