describe SearchHelper do
  describe "#proposal_status_options" do
    it "returns options list for proposal status" do
      expect(helper.proposal_status_options("")).to include(%Q(<option value="*">All Requests</option>))
    end
  end

  describe "#proposal_status_value" do
    it "maps a search field term to a friendly label" do
      expect(helper.proposal_status_value("*")).to eq("All Requests")
    end
  end

  describe "#proposal_expense_type_options" do
    it "returns options list for model with expense types" do
      expect(helper.proposal_expense_type_options(Ncr::WorkOrder, "")).to include(%Q(<option value="*">Any type</option>))
    end
  end
end
