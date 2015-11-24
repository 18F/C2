module EnvironmentSpecHelper
  def with_18f_procurement_env_variables(&block)
    with_env_vars({
      DISABLE_SANDBOX_WARNING: 'true'
    }, &block)
  end
end
