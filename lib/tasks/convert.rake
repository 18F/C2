namespace :convert do
  namespace :roles do
    desc "migrate NCR env var budget approvers to Roles"
    task ncr_budgets: :environment do
      RolesConversion.ncr_budget_approvers()
    end
  end
end
