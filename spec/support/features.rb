# https://github.com/rspec/rspec-core/issues/1378#issuecomment-37248037
def with_env_vars(env={}, &block)
  context "with ENV vars #{env}" do
    env = env.stringify_keys
    around(:each) do |example|
      old_values = {}
      env.each_key{ |k| old_values[k] = ENV[k] }
      env.each{ |k, v| ENV[k] = v }
      example.run
      old_values.each{ |k, v| ENV[k] = v}
    end

    class_exec(&block)
  end
end

def with_env_var(name, val, &block)
  with_env_vars({name => val}, &block)
end

def with_feature(name, &block)
  with_env_var(name, 'true', &block)
end

def without_feature(name, &block)
  with_env_var(name, nil, &block)
end
