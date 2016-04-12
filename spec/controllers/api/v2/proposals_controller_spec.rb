describe Api::ProposalsController do
  include EnvVarSpecHelper

  describe "API_ENABLED env var" do
    it "gives a 403 when set to false" do
      with_env_var("API_ENABLED", "false") do
        get :index
        json = JSON.parse(response.body)
        expect(response.status).to eq(403)
        expect(json["error"]).to eq("Not authorized")
      end
    end
  end

  describe "#show" do
    it "fetches a specific proposal" do
      with_env_var("API_ENABLED", "true") do
        user = mock_api_doorkeeper_pass
        test_request = create(:test_client_request, :with_approvers, requester: user)

        login_as(user)
        get :show, id: test_request.proposal.id

        expect(response.status).to eq(200)
        expect(response.body).to eq(ProposalSerializer.new(test_request.proposal).to_json)
      end
    end
  end

  describe "#index" do
    it "fetches a list of proposals", :elasticsearch do
      with_env_var("API_ENABLED", "true") do
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
  end
end
