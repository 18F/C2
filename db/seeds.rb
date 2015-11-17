# any commands in this file should be idempotent
Role.find_or_create_by(name: 'observer')
Role.find_or_create_by(name: 'client_admin')
Role.find_or_create_by(name: 'admin')

# RolesConversion relies upon some ENV variables to set the initial User records.
# it should be safe to run multiple times in the same environment, and to remove
# the relevant ENV vars after it has run at least once.
RolesConversion.new.ncr_budget_approvers
RolesConversion.new.gsa18f_approvers
