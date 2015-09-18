# any commands in this file should be idempotent
Role.find_or_create_by(name: 'observer')
Role.find_or_create_by(name: 'client_admin')
Role.find_or_create_by(name: 'admin')

RolesConversion.ncr_budget_approvers
