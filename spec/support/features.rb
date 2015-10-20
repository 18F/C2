# TODO move to a gem

## private methods ##

def in_spec?
  !respond_to?(:describe)
end

# insertion in RSpec not supported by Climate Control directly
# https://github.com/thoughtbot/climate_control/pull/14
def with_env_vars_around(env, &block)
  # https://github.com/rspec/rspec-core/issues/1378#issuecomment-37248037
  context "with ENV vars #{env}" do
    around(:each) do |example|
      ClimateControl.modify(env) do
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
    ClimateControl.modify(env, &block)
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
