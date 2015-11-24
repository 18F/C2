require_relative "../../../db/chores/roles_conversion"

describe RolesConversion do
  describe "#ncr_budget_approvers" do
    it "should convert NCR budget approvers" do
      expect {
        RolesConversion.new.ncr_budget_approvers
      }.to_not change { User.count }
    end

    it "should be idempotent based on client_slug+role" do
      with_env_var('NCR_BA61_TIER1_BUDGET_MAILBOX', 'someoneelse@example.com') do
        expect {
          RolesConversion.new.ncr_budget_approvers
        }.to_not change { User.count }
      end
    end
  end
end
