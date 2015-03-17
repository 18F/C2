describe Ncr::WorkOrder do
  describe 'fields_for_display' do
    it "shows BA61 fields" do
      wo = Ncr::WorkOrder.new(
        amount: 1000, expense_type: "BA61", vendor: "Some Vend", 
        not_to_exceed: false, emergency: true, rwa_number: "RWWAAA #",
        building_number: Ncr::WorkOrder::BUILDING_NUMBERS[0],
        office: Ncr::WorkOrder::OFFICES[0])
      fields = wo.fields_for_display
      expect(fields).to include(["Amount", 1000])
      expect(fields).to include(["Expense type", "BA61"])
      expect(fields).to include(["Vendor", "Some Vend"])
      expect(fields).to include(["Not to exceed", false])
      expect(fields).to include(["Emergency", true])
      expect(fields).to include(["Building number",
                                 Ncr::WorkOrder::BUILDING_NUMBERS[0]])
      expect(fields).not_to include(["RWA Number", "RWWAAA #"])
      expect(fields).to include(["Office", Ncr::WorkOrder::OFFICES[0]])
    end
    it "shows BA80 fields" do
      wo = Ncr::WorkOrder.new(
        amount: 1000, expense_type: "BA80", vendor: "Some Vend", 
        not_to_exceed: false, emergency: true, rwa_number: "RWWAAA #",
        building_number: Ncr::WorkOrder::BUILDING_NUMBERS[0],
        office: Ncr::WorkOrder::OFFICES[0])
      fields = wo.fields_for_display
      expect(fields).to include(["Amount", 1000])
      expect(fields).to include(["Expense type", "BA80"])
      expect(fields).to include(["Vendor", "Some Vend"])
      expect(fields).to include(["Not to exceed", false])
      expect(fields).not_to include(["Emergency", true])
      expect(fields).to include(["Building number",
                                 Ncr::WorkOrder::BUILDING_NUMBERS[0]])
      expect(fields).to include(["RWA Number", "RWWAAA #"])
      expect(fields).to include(["Office", Ncr::WorkOrder::OFFICES[0]])
    end
  end
end
