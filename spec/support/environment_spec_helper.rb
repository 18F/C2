module EnvironmentSpecHelper
  def with_18f_procurement_env_variables
    old_approver_email = ENV['GSA18F_APPROVER_EMAIL']
    old_purchaser_email = ENV['GSA18F_PURCHASER_EMAIL']

    ENV['GSA18F_APPROVER_EMAIL'] = 'test_approver@some-dot-gov.gov'
    ENV['GSA18F_PURCHASER_EMAIL'] = 'test_purchaser@some-dot-gov.gov'
    yield
    ENV['GSA18F_APPROVER_EMAIL'] = old_approver_email
    ENV['GSA18F_PURCHASER_EMAIL'] = old_purchaser_email
  end
end