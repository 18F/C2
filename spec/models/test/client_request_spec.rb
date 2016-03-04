describe Test::ClientRequest do
  it_behaves_like "client data"

  describe "#editable?" do
    it "is true" do
      client_request = build(:test_client_request)
      expect(client_request).to be_editable
    end
  end

  describe "#csv_fields" do
    it "serializes associations" do
      client_request = create(:test_client_request)
      expect(client_request.csv_fields).to eq([
        client_request.amount,
        client_request.approving_official,
        client_request.created_at,
        client_request.id,
        client_request.name,
        client_request.updated_at
      ])
    end
  end
end
