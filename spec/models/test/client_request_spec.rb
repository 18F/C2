describe Test::ClientRequest do
  it_behaves_like "client data"

  describe "#editable?" do
    it "is true" do
      client_request = build(:test_client_request)
      expect(client_request).to be_editable
    end
  end

end
