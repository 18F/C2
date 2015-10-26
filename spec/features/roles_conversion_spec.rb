describe RolesConversion do
  describe "#ncr_budget_approvers" do
    it "should convert NCR budget approvers" do
      expect(User.count).to eq(4) # via db/seeds
      RolesConversion.new.ncr_budget_approvers
      expect(User.count).to eq(4) # no change (idempotent)
    end

    it "should be idempotent based on client_slug+role" do
      with_env_var('NCR_BA61_TIER1_BUDGET_MAILBOX', 'someoneelse@example.com') do
        expect(User.count).to eq(4) # via db/seeds
        RolesConversion.new.ncr_budget_approvers
        expect(User.count).to eq(4) # no change (idempotent)
      end
    end
  end
end
