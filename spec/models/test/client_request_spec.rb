describe Test::ClientRequest do
  it_behaves_like "client data"

  describe "#editable?" do
    it "is true" do
      client_request = build(:test_client_request)
      expect(client_request).to be_editable
    end
  end

  describe "#as_indexed_json" do
    it "serializes associations automatically" do
      client_request = build(:test_client_request)

      indexable = client_request.as_json
      indexable[:approving_official] = client_request.approving_official.as_json

      expect(client_request.as_indexed_json).to eq(indexable)
    end
  end
end
