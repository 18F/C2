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
  end
end
