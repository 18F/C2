describe AttachmentsController do
  describe 'permission checking' do
    let (:proposal) { create(:proposal, :with_parallel_approvers, :with_observers) }
    let (:params) {{
      proposal_id: proposal.id,
      attachment: fixture_file_upload('icon-user.png', 'image/png')
    }}

    before do
      stub_request(:put, /.*c2-prod.s3.amazonaws.com.*/)
    end

    it "allows the requester to add an attachment" do
      login_as(proposal.requester)
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:error]).not_to be_present
      expect(response).to redirect_to(proposal)
      expect(proposal.attachments.count).to eq(1)
    end

    it "allows an approver to add an attachment" do
      login_as(proposal.approvers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
      expect(proposal.attachments.count).to eq(1)
    end

    it "allows an observer to add an attachment" do
      login_as(proposal.observers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
      expect(proposal.attachments.count).to eq(1)
    end

    it "does not allow others to add an attachment" do
      login_as(create(:user))
      post :create, params
      expect(flash[:success]).not_to be_present
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(proposals_path)
      expect(proposal.attachments.count).to eq(0)
    end
  end

  describe 'error handling' do
    it "gives an error when a file was not selected" do
      proposal = create(:proposal)
      login_as(proposal.requester)
      post :create, { proposal_id: proposal.id }
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      expect(response).to redirect_to(proposal_path(proposal))
      expect(proposal.attachments.count).to eq(0)
    end
  end

  describe '#show' do
    let (:proposal) { create(:proposal, :with_parallel_approvers, :with_observers) }
    let (:attachment) { create(:attachment, proposal: proposal, user: proposal.requester) }

    it "allows the requester to view attachment" do
      login_as(proposal.requester)
      get :show, proposal_id: proposal.id, id: attachment.id
      expect(response).to redirect_to(attachment.url)
    end

    it "allows the approver to view attachment" do
      login_as(proposal.approvers[0])
      get :show, proposal_id: proposal.id, id: attachment.id
      expect(response).to redirect_to(attachment.url)
    end

    it "allows the observer to view attachment" do
      login_as(proposal.observers[0])
      get :show, proposal_id: proposal.id, id: attachment.id
      expect(response).to redirect_to(attachment.url)
    end

    it "does not allow others to view attachment" do
      login_as(create(:user))
      get :show, proposal_id: proposal.id, id: attachment.id
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(proposals_path)
    end
  end
end
