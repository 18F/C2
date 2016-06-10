require_relative "chores/roles_conversion"
require 'seed_report'

# Any commands in this file should be idempotent
SeedReport.for_model Role do
  %w(observer client_admin admin).each { |r| Role.find_or_create_by!(name: r) }
end

# RolesConversion relies upon some ENV variables to set the initial User records. it
# should be safe to run multiple times in the same environment, and to remove the relevant
# ENV vars after it has run at least once.
RolesConversion.new.ncr_budget_approvers
RolesConversion.new.gsa18f_approvers
