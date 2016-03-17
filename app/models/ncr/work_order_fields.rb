module Ncr
  class WorkOrderFields
    def initialize(work_order = nil)
      @work_order = work_order
    end

    def relevant(expense_type)
      fields = default

      if expense_type == "BA61"
        fields << :emergency
      elsif expense_type == "BA80"
        fields += [:rwa_number, :code]
      end

      fields
    end

    def display
      attributes_for_view.push(
        ["Org code", work_order.organization_code_and_name],
        ["Approving official", work_order.approving_official.try(:email_address)]
      )
    end

    def email_display
      [
        [amount_and_not_to_exceed, work_order.amount],
        ["CL#", work_order.cl_number],
        ["Expense Type", work_order.expense_type],
        ["Function Code", work_order.function_code],
        ["Vendor", work_order.vendor],
        ["Object Field / SOC code", work_order.soc_code],
        ["Building Number", work_order.building_number],
        ["Org Code", work_order.organization_code_and_name],
        ["Direct Pay", work_order.direct_pay],

      ]
    end

    def top_email_field
      work_order.description
    end

    private

    attr_reader :work_order

    def default
      [
        :amount,
        :approving_official_id,
        :building_number,
        :cl_number,
        :description,
        :direct_pay,
        :expense_type,
        :function_code,
        :ncr_organization_id,
        :not_to_exceed,
        :project_title,
        :soc_code,
        :vendor,
      ]
    end

    def attributes_for_view
      attributes = relevant(work_order.expense_type) - [:ncr_organization_id, :approving_official_id]
      attributes.map do |attribute|
        [
          Ncr::WorkOrder.human_attribute_name(attribute),
          work_order.send(attribute)
        ]
      end
    end

    def amount_and_not_to_exceed
      if work_order.not_to_exceed?
        "Not to exceed / Amount"
      else
        "Amount"
      end
    end
  end
end
