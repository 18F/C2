describe RolesConversion do
  describe "#ncr_budget_approvers" do
    it "should convert NCR budget approvers" do
      expect(User.count).to eq(4) # via db/seeds
      RolesConversion.new.ncr_budget_approvers
      expect(User.count).to eq(4) # no change (idempotent)
    end
  end
end
