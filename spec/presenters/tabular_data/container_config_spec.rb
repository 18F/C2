describe TabularData::ContainerConfig do
  describe "#settings" do
    it "returns config for client" do
      stub_const("TabularData::ContainerConfig::CONFIG_FILE_PATH", "#{Rails.root}/spec/support/fixtures/")
      config = TabularData::ContainerConfig.new("container_config", "generic_client").settings

      expect(config).to eq({
        :engine => "Proposal",
        :columns => ["client_column"]
      })
    end
  end
end
