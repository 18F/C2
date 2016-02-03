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
      attributes_for_view.push(["Org code", work_order.organization_code_and_name])
    end

    private

    attr_reader :work_order

    def default
      [
        :amount,
        :approving_official_email,
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
      attributes = relevant(work_order.expense_type) - [:ncr_organization_id]
      attributes.map do |attribute|
        [
          Ncr::WorkOrder.human_attribute_name(attribute),
          work_order.send(attribute)
        ]
      end
    end
  end
end
