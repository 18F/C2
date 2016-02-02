describe Ncr::WorkOrderFields do
  describe "#relevant" do
    it "shows BA61 fields" do
      fields = Ncr::WorkOrderFields.new.relevant("BA61").sort

      expect(fields).to eq([
        :amount,
        :approving_official_email,
        :building_number,
        :cl_number,
        :description,
        :direct_pay,
        :emergency,
        :expense_type,
        :function_code,
        :ncr_organization_id,
        :not_to_exceed,
        :project_title,
        :soc_code,
        :vendor
      ])
    end

    it "shows BA80 fields" do
      fields = Ncr::WorkOrderFields.new.relevant("BA80").sort

      expect(fields).to eq([
        :amount,
        :approving_official_email,
        :building_number,
        :cl_number,
        :code,
        :description,
        :direct_pay,
        :expense_type,
        :function_code,
        :ncr_organization_id,
        :not_to_exceed,
        :project_title,
        :rwa_number,
        :soc_code,
        :vendor
      ])
    end
  end

  describe "#display" do
    it "returns relevant fields for the work order passed in" do
      work_order = build(:ncr_work_order, expense_type: "BA61")

      fields = Ncr::WorkOrderFields.new(work_order).display

      expect(fields).to eq([
         ["Amount", work_order.amount],
         ["Approving official email", work_order.approving_official_email],
         ["Building number", work_order.building_number],
         ["CL number", work_order.cl_number],
         ["Description", work_order.description],
         ["Direct pay", work_order.direct_pay],
         ["Expense type", work_order.expense_type],
         ["Function code", work_order.function_code],
         ["Not to exceed", work_order.not_to_exceed],
         ["Project title", work_order.project_title],
         ["Object field / SOC code", work_order.soc_code],
         ["Vendor", work_order.vendor],
         ["Emergency", work_order.emergency],
         ["Org code", work_order.organization_code_and_name],
      ])
    end
  end
end
