# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.find_or_create_by(name: 'observer')
Role.find_or_create_by(name: 'client_admin')
Role.find_or_create_by(name: 'admin')

User.with_email_role_slug!(
  ENV['NCR_BA61_TIER1_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com',
  'BA61_tier1_budget_approver',
  'ncr'
)
User.with_email_role_slug!(
  ENV['NCR_BA61_TIER2_BUDGET_MAILBOX'] || 'communicart.ofm.approver@gmail.com',
  'BA61_tier2_budget_approver',
  'ncr'
)
User.with_email_role_slug!(
  ENV['NCR_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com',
  'BA80_budget_approver',
  'ncr'
)
User.with_email_role_slug!(
  ENV['NCR_OOL_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com',
  'OOL_BA80_budget_approver',
  'ncr'
)
