class RolesConversion
  def self.ncr_budget_approvers
    self.ba61_tier1_budget_approver
    self.ba61_tier2_budget_approver
    self.ba80_budget_approver
    self.ool_ba80_budget_approver
  end

  def self.ba61_tier1_budget_approver
    User.with_email_role_slug!(
      ENV['NCR_BA61_TIER1_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com',
      'BA61_tier1_budget_approver',
      'ncr'
    )
  end

  def self.ba61_tier2_budget_approver
    User.with_email_role_slug!(
      ENV['NCR_BA61_TIER2_BUDGET_MAILBOX'] || 'communicart.ofm.approver@gmail.com',
      'BA61_tier2_budget_approver',
      'ncr'
    )
  end

  def self.ba80_budget_approver
    User.with_email_role_slug!(
      ENV['NCR_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com',
      'BA80_budget_approver',
      'ncr'
    )
  end

  def self.ool_ba80_budget_approver
    User.with_email_role_slug!(
      ENV['NCR_OOL_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com',
      'OOL_BA80_budget_approver',
      'ncr'
    )
  end
end
