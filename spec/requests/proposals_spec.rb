describe 'proposals' do
  include ReturnToHelper

  describe 'GET /proposals/:id' do
    it "can be viewed by a delegate" do
      proposal = FactoryGirl.create(:proposal)
      approver = FactoryGirl.create(:user, :with_delegate)
      proposal.approvals.create!(user: approver, status: 'actionable')

      delegate = approver.outgoing_delegates.first.assignee
      login_as(delegate)

      get "/proposals/#{proposal.id}"

      expect(response.status).to eq(200)
    end
  end

  describe 'POST /proposals/:id/approve' do
    def expect_status(proposal, status, app_status)
      proposal.reload
      proposal.approvals.each do |approval|
        expect(approval.status).to eq(app_status)
      end
      expect(proposal.status).to eq(status)
    end

    it "fails if not signed in" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      post "/proposals/#{proposal.id}/approve"

      expect(response.status).to redirect_to(root_path(return_to: self.make_return_to("Previous", request.fullpath)))
      expect_status(proposal, 'pending', 'actionable')
    end

    it "fails if user is not involved with the request" do
      proposal = FactoryGirl.create(:proposal)
      stranger = FactoryGirl.create(:user)
      login_as(stranger)

      post "/proposals/#{proposal.id}/approve"

      expect(response.status).to redirect_to('/proposals')
      expect_status(proposal, 'pending', 'actionable')
    end

    it "succeeds as a delegate" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approver = proposal.approvers.first

      # TODO move to factory trait
      delegate = FactoryGirl.create(:user)
      approver.add_delegate(delegate)

      login_as(delegate)

      post "/proposals/#{proposal.id}/approve"

      expect_status(proposal, 'approved', 'approved')
    end

    context "signed in as the approver" do
      let(:proposal) { FactoryGirl.create(:proposal, :with_approver) }
      let(:approver) { proposal.approvers.first }

      before do
        login_as(approver)
      end

      it "updates the status of the Proposal" do
        post "/proposals/#{proposal.id}/approve"

        expect(response).to redirect_to("/proposals/#{proposal.id}")
        expect_status(proposal, 'approved', 'approved')
      end

      describe "version number" do
        it "works if the version matches" do
          expect_any_instance_of(Proposal).to receive(:version).and_return(123)
          post "/proposals/#{proposal.id}/approve", version: 123
          expect_status(proposal, 'approved', 'approved')
        end

        it "fails if the versions don't match" do
          expect_any_instance_of(Proposal).to receive(:version).and_return(456)
          post "/proposals/#{proposal.id}/approve", version: 123
          expect_status(proposal, 'pending', 'actionable')
          # TODO check for message on the page
        end
      end
    end

    context "using a token" do
      let(:proposal) { FactoryGirl.create(:proposal, :with_approver) }
      let(:approval) { proposal.approvals.first }
      let(:token) { approval.api_token }

      it "supports token auth" do
        post "/proposals/#{proposal.id}/approve", cch: token.access_token

        expect(response).to redirect_to("/proposals/#{proposal.id}")
        expect_status(proposal, 'approved', 'approved')
      end

      it "marks the token as used" do
        post "/proposals/#{proposal.id}/approve", cch: token.access_token

        token.reload
        expect(token).to be_used
      end
    end
  end
end
