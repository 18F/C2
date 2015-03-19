describe Ncr::WorkOrder do
  describe 'fields_for_display' do
    it "shows BA61 fields" do
      wo = Ncr::WorkOrder.new(
        amount: 1000, expense_type: "BA61", vendor: "Some Vend", 
        not_to_exceed: false, emergency: true, rwa_number: "RWWAAA #",
        building_number: Ncr::WorkOrder::BUILDING_NUMBERS[0],
        office: Ncr::WorkOrder::OFFICES[0])
      expect(wo.fields_for_display.sort).to eq([
        ["Amount", 1000],
        ["Building number", Ncr::WorkOrder::BUILDING_NUMBERS[0]],
        ["Emergency", true],
        ["Expense type", "BA61"],
        ["Not to exceed", false],
        ["Office", Ncr::WorkOrder::OFFICES[0]],
        # No RWA Number
        ["Vendor", "Some Vend"]
      ])
    end
    it "shows BA80 fields" do
      wo = Ncr::WorkOrder.new(
        amount: 1000, expense_type: "BA80", vendor: "Some Vend", 
        not_to_exceed: false, emergency: true, rwa_number: "RWWAAA #",
        building_number: Ncr::WorkOrder::BUILDING_NUMBERS[0],
        office: Ncr::WorkOrder::OFFICES[0])
      expect(wo.fields_for_display.sort).to eq([
        ["Amount", 1000],
        ["Building number", Ncr::WorkOrder::BUILDING_NUMBERS[0]],
        # No Emergency
        ["Expense type", "BA80"],
        ["Not to exceed", false],
        ["Office", Ncr::WorkOrder::OFFICES[0]],
        ["RWA Number", "RWWAAA #"],
        ["Vendor", "Some Vend"]
      ])
    end
  end
end
