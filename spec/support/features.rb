# TODO move to a gem

## private methods ##

def in_spec?
  !respond_to?(:describe)
end

def with_env_vars_runner(env)
  env = env.stringify_keys
  old_values = {}
  env.each_key { |k| old_values[k] = ENV[k] }
  env.each { |k, v| ENV[k] = v }
  yield
  old_values.each { |k, v| ENV[k] = v }
end

# https://github.com/rspec/rspec-core/issues/1378#issuecomment-37248037
def with_env_vars_around(env, &block)
  context "with ENV vars #{env}" do
    around(:each) do |example|
      with_env_vars_runner(env) do
        example.run
      end
    end

    class_exec(&block)
  end
end

#####################

## public methods, that can be used in or around specs ##

def with_env_vars(env, &block)
  if in_spec?
    with_env_vars_runner(env, &block)
  else
    with_env_vars_around(env, &block)
  end
end

def with_env_var(name, val, &block)
  with_env_vars({ name => val }, &block)
end

def with_feature(name, &block)
  with_env_var(name, 'true', &block)
end

def without_feature(name, &block)
  with_env_var(name, nil, &block)
end

#########################################################
