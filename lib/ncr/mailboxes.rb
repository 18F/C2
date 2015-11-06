module Ncr
  module Mailboxes
    def self.ba61_tier1_budget
      self.approver_with_role("BA61_tier1_budget_approver")
    end

    def self.ba61_tier2_budget
      self.approver_with_role("BA61_tier2_budget_approver")
    end

    def self.ba80_budget
      self.approver_with_role("BA80_budget_approver")
    end

    def self.ool_ba80_budget
      self.approver_with_role("OOL_BA80_budget_approver")
    end

    protected

    def self.approver_with_role(role_name)
      users = User.with_role(role_name).where(client_slug: "ncr")
      if users.empty?
        fail "Missing User with role #{role_name} -- did you run rake db:migrate and rake db:seed?"
      end
      users.first.email_address
    end
  end
end
