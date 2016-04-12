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

      indexable = client_request.as_json(include: [:approving_official])

      expect(client_request.as_indexed_json).to eq(indexable)
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

  describe "#initialize_steps" do
    it "currently does nothing" do
      client_request = create(:test_client_request)
      expect(client_request.proposal.steps.count).to eq(0)
      expect(client_request.initialize_steps).to eq nil
      expect(client_request.proposal.steps.count).to eq(0)
    end
  end

  describe "#permitted_params" do
    it "returns hash of allowed parameters" do
      params = ActionController::Parameters.new({ test_client_request: { amount: 123, project_title: "foo" } })
      expect(Test::ClientRequest.permitted_params(params, nil)).to eq params[:test_client_request]
    end
  end

  describe "#setup_and_email_subscribers" do
    it "currently does nothing" do
      client_request = create(:test_client_request)
      expect(client_request.setup_and_email_subscribers("hello world")).to eq nil
      expect(deliveries.count).to eq 0
    end
  end

  describe "#normalize_input" do
    it "currently does nothing" do
      client_request = create(:test_client_request)
      expect(client_request.normalize_input).to eq nil
    end
  end
end
