describe Api::ProposalsController do
  describe "#show" do
    it "fetches a specific proposal" do
      user = mock_api_doorkeeper_pass
      test_request = create(:test_client_request, :with_approvers, requester: user)

      get :show, id: test_request.proposal.id

      expect(response.status).to eq(200)
      expect(response.body).to eq(ProposalSerializer.new(test_request.proposal).to_json)
    end
  end

  describe "#index" do
    xit "fetches a list of proposals", :elasticsearch do
      es_execute_with_retries 3 do
        user = mock_api_doorkeeper_pass
        test_requests = 3.times.map do |i|
          tr = create(:test_client_request, :with_approvers, requester: user)
          tr.proposal.reindex
          tr
        end
        Proposal.__elasticsearch__.refresh_index!

        get :index, text: "test request"

        expect(response.status).to eq(200)
        result = JSON.parse(response.body)
        expect(result["total"]).to eq(3)
        expect(result["proposals"].size).to eq(3)
      end
    end
  end

  describe "#create" do
    it "respects client type on initial POST" do
      user = mock_api_doorkeeper_pass

      post :create, new_proposal

      expect(response.status).to eq(200)

      created_proposal = JSON.parse(response.body)
      proposal = Proposal.find(created_proposal["id"])
      expect(proposal.client_data_type).to eq "Test::ClientRequest"
      expect(proposal.client_data.project_title).to eq(new_proposal[:test_client_request][:project_title])
    end

    it "returns errors when sent invalid params" do
      user = mock_api_doorkeeper_pass

      post :create, { test_client_request: { project_title: "missing amount" } }

      payload = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(payload["errors"]).to include("Amount must be greater than or equal to $1.00")
    end
  end

  describe "#update" do
    it "updates params" do
      user = mock_api_doorkeeper_pass
      proposal = create(:proposal, requester: user)
      test_request = create(:test_client_request, proposal: proposal)

      put :update, id: proposal.id, test_client_request: { amount: 456.78 }

      expect(response.status).to eq(200)
      proposal.reload
      expect(proposal.client_data.amount).to eq(456.78)
    end
  end

  def new_proposal
    {
      test_client_request: {
        project_title: "i am a test",
        amount: 123.00
      }
    }
  end
end
