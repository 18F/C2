require_relative "chores/roles_conversion"

#
# Any commands in this file should be idempotent
#

Role.ensure_system_roles_exist

# RolesConversion relies upon some ENV variables to set the initial User records.
# it should be safe to run multiple times in the same environment, and to remove
# the relevant ENV vars after it has run at least once.
RolesConversion.new.ncr_budget_approvers
RolesConversion.new.gsa18f_approvers
