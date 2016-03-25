describe Ncr::WorkOrderFields do
  describe "#relevant" do
    it "shows BA61 fields" do
      fields = Ncr::WorkOrderFields.new.relevant("BA61").sort

      expect(fields).to eq([
        :amount,
        :approving_official_id,
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
        :approving_official_id,
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
end
