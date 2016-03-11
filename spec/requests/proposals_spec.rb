describe "proposals" do
  include EnvVarSpecHelper
  include ReturnToHelper

  describe "DISABLE_CLIENT_SLUGS" do
    it "disallows any request for disabled client_slug" do
      with_env_var("DISABLE_CLIENT_SLUGS", "foo") do
        allow(Proposal).to receive(:client_slugs).and_return(%w(foo))
        proposal = create(:proposal)
        user = create(:user, client_slug: "foo")
        endpoints = [proposal_path(proposal), proposals_path]

        endpoints.each do |endpoint|
          login_as(user)
          get endpoint
          expect(response.status).to eq 403
          expect(response.body).to match "Client is disabled"
        end
      end
    end
  end

  describe 'GET /proposals/:id' do
    it "can be viewed by a delegate" do
      delegate = create(:user)
      proposal = create(:proposal, delegate: delegate)

      login_as(delegate)
      get "/proposals/#{proposal.id}"

      expect(response.status).to eq(200)
    end
  end

  describe 'POST /proposals/:id/complete' do
    def expect_status(proposal, status, app_status)
      proposal.reload
      proposal.steps.each do |approval|
        expect(approval.status).to eq(app_status)
      end
      expect(proposal.status).to eq(status)
    end

    it "fails if not signed in" do
      proposal = create(:proposal, :with_approver)
      post "/proposals/#{proposal.id}/complete"

      expect(response.status).to redirect_to(root_path(return_to: make_return_to("Previous", request.fullpath)))
      expect_status(proposal, 'pending', 'actionable')
    end

    it "fails if user is not involved with the request" do
      proposal = create(:proposal)
      stranger = create(:user)
      login_as(stranger)

      post "/proposals/#{proposal.id}/complete"

      expect(response.status).to eq(403)
      expect_status(proposal, 'pending', 'actionable')
    end

    it "succeeds as a delegate" do
      delegate = create(:user)
      proposal = create(:proposal, delegate: delegate)

      login_as(delegate)
      post "/proposals/#{proposal.id}/complete"

      expect_status(proposal, 'completed', 'completed')
    end

    context "signed in as the approver" do
      let(:proposal) { create(:proposal, :with_approver) }
      let(:approver) { proposal.approvers.first }

      before do
        login_as(approver)
      end

      it "updates the status of the Proposal" do
        post "/proposals/#{proposal.id}/complete"

        expect(response).to redirect_to("/proposals/#{proposal.id}")
        expect_status(proposal, 'completed', 'completed')
      end

      describe "version number" do
        it "works if the version matches" do
          expect_any_instance_of(Proposal).to receive(:version).and_return(123)
          post "/proposals/#{proposal.id}/complete", version: 123
          expect_status(proposal, 'completed', 'completed')
        end

        it "fails if the versions don't match" do
          expect_any_instance_of(Proposal).to receive(:version).and_return(456)
          post "/proposals/#{proposal.id}/complete", version: 123
          expect_status(proposal, 'pending', 'actionable')
          # TODO check for message on the page
        end
      end
    end

    context "using a token" do
      let(:proposal) { create(:proposal, :with_approver) }
      let(:step) { proposal.individual_steps.first }
      let(:token) { create(:api_token, step: step) }

      it "supports token auth" do
        post "/proposals/#{proposal.id}/complete", cch: token.access_token

        expect(response).to redirect_to("/proposals/#{proposal.id}")
        expect_status(proposal, 'completed', 'completed')
      end

      it "marks the token as used" do
        post "/proposals/#{proposal.id}/complete", cch: token.access_token

        token.reload
        expect(token).to be_used
      end

      it "fails for delegate without login, redirects automatically after login" do
        delegate = create(:user)
        proposal = create(:proposal, delegate: delegate)
        step = proposal.individual_steps.first
        token = create(:api_token, step: step)

        get "/proposals/#{proposal.id}/complete", cch: token.access_token

        expect(response).to redirect_to(root_path(return_to: make_return_to("Previous", request.fullpath)))

        login_as(delegate)

        expect(response).to redirect_to("/proposals/#{proposal.id}/complete?cch=#{token.access_token}")

        get response.headers['Location']

        expect_status(proposal, 'completed', 'completed')
        expect(session[:return_to]).to be_nil
        expect(session[:user]).to_not be_nil
      end
    end
  end
end
