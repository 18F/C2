describe CloudFoundry do
  describe '.app_url' do
    with_env_var('VCAP_APPLICATION', nil) do
      it "returns nil" do
        expect(CloudFoundry.app_url).to eq(nil)
      end
    end

    with_env_var('VCAP_APPLICATION', { application_uris: [] }.to_json) do
      it "returns nil" do
        expect(CloudFoundry.app_url).to eq(nil)
      end
    end

    with_env_var('VCAP_APPLICATION', { application_uris: ['foo.bar.com'] }.to_json) do
      it "returns the URI" do
        expect(CloudFoundry.app_url).to eq('foo.bar.com')
      end
    end

    with_env_var('VCAP_APPLICATION', { application_uris: ['foo.bar.com', 'short.com', 'baz.longerdomain.com'] }.to_json) do
      it "returns the shortest URI" do
        expect(CloudFoundry.app_url).to eq('short.com')
      end
    end
  end
end
