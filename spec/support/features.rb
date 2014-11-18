# https://github.com/rspec/rspec-core/issues/1378#issuecomment-37248037
def with_env_var(name, val, &block)
  context "with #{name}=#{val}" do
    around(:each) do |example|
      old_val = ENV[name]
      ENV[name] = val
      example.run
      ENV[name] = old_val
    end

    class_exec(&block)
  end
end

def with_feature(name, &block)
  with_env_var(name, 'true', &block)
end

def without_feature(name, &block)
  with_env_var(name, nil, &block)
end
