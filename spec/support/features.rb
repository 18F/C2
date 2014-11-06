# https://github.com/rspec/rspec-core/issues/1378#issuecomment-37248037
def with_feature(name, &block)
  context "with #{name} enabled" do
    around(:each) do |example|
      old_val = ENV[name]
      ENV[name] = 'true'
      example.run
      ENV[name] = old_val
    end

    class_exec(&block)
  end
end
