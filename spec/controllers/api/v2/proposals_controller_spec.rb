describe Api::ProposalsController do
  before(:all) do
    ENV["API_ENABLED"] = "true"
  end

  let(:token) { double :acceptable? => true }

  before do
    allow(controller).to receive(:doorkeeper_token) {token} # => RSpec 3
  end

  describe "GET" do
    it "fetches a specific proposal" do
      test_request = create(:test_client_request, :with_approvers)

      login_as(test_request.proposal.requester)
      get :show, id: test_request.proposal.id

      expect(response.status).to eq(200)
      expect(response.body).to eq(ProposalSerializer.new(test_request.proposal).to_json)
    end

    it "fetches a list of proposals", :elasticsearch do
      es_execute_with_retries 3 do
        user = create(:user, client_slug: "test")
        test_requests = 3.times.map do |i|
          tr = create(:test_client_request, :with_approvers, requester: user)
          tr.proposal.reindex
          tr
        end
        Proposal.__elasticsearch__.refresh_index!

        login_as(user)
        get :index, text: "test request"

        expect(response.status).to eq(200)
        result = JSON.parse(response.body)
        expect(result["total"]).to eq(3)
        expect(result["proposals"].size).to eq(3)
      end
    end
  end
end
