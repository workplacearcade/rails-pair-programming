# frozen_string_literal: true

module IQMetrix
  class PerformanceGroup < ApplicationRecord
    self.table_name = 'iq_metrix_performance_groups'

    belongs_to :iq_metrix_partner, class_name: 'IQMetrix::Partner'

    belongs_to :kpi_group

    validates_inclusion_of :quantity_attribute, in: ['quantity', 'gross_profit', 'total_cost', 'carrier_price', 'total_price']

    def query_sales(start_time: 15.minutes.ago, end_time: Time.zone.now, employee_ids: nil)
      [
        { 
          'ProductIdentifier' => 'SKU123',
          'EmployeeID' => '1', 
          'EmployeeUsername' => 'james.mclaren', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 1
        },
        { 
          'ProductIdentifier' => 'SKU234',
          'EmployeeID' => '1', 
          'EmployeeUsername' => 'james.mclaren', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 2
        },
        { 
          'ProductIdentifier' => 'SKU345',
          'EmployeeID' => '2', 
          'EmployeeUsername' => 'david.parry', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 3
        },
        { 
          'ProductIdentifier' => 'SKU456',
          'EmployeeID' => '2', 
          'EmployeeUsername' => 'david.parry', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 4
        },
        { 
          'ProductIdentifier' => 'SKU567',
          'EmployeeID' => '7', 
          'EmployeeUsername' => 'odisha.odicho', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 5
        },
        { 
          'ProductIdentifier' => 'SKU789',
          'EmployeeID' => '7', 
          'EmployeeUsername' => 'odisha.odicho', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 6
        },
        { 
          'ProductIdentifier' => 'SKU888',
          'EmployeeID' => '4', 
          'EmployeeUsername' => 'sharon.chen', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 7
        },
        { 
          'ProductIdentifier' => 'SKU999',
          'EmployeeID' => '4', 
          'EmployeeUsername' => 'sharon.chen', 
          'InvoicedAt' => 'Melbourne', 
          'Quantity' => 1,
          'SaleInvoiceProductRowId' => 8
        },
      ]
    end
  end
end
