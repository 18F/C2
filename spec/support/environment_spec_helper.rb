module EnvironmentSpecHelper
  def with_18f_procurement_env_variables(&block)
    with_env_vars({
      DISABLE_SANDBOX_WARNING: 'true',
      GSA18F_APPROVER_EMAIL: 'test_approver@some-dot-gov.gov',
      GSA18F_PURCHASER_EMAIL: 'test_purchaser@some-dot-gov.gov'
    }, &block)
  end
end
