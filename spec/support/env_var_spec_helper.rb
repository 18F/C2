module EnvVarSpecHelper
  def with_env_vars(env, &block)
    ClimateControl.modify(env, &block)
  end

  def with_env_var(name, val, &block)
    with_env_vars({ name => val }, &block)
  end
end
