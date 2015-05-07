describe ProposalsController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    before do
      login_as(user)
    end

    it 'sets @proposals' do
      proposal1 = FactoryGirl.create(:proposal, requester: user)
      proposal2 = FactoryGirl.create(:proposal)
      proposal2.approvals.create!(user: user)

      get :index
      expect(assigns(:proposals).sort).to eq [proposal1, proposal2]
    end
  end

  describe '#archive' do
    before do
      login_as(user)
    end

    it 'should show all the closed proposals' do
      open_proposals = 2.times.map do |i|
        FactoryGirl.create(:proposal, requester: user, status: 'approved')
      end
      FactoryGirl.create(:proposal, requester: user)

      get :archive

      expect(assigns(:proposals).size).to eq(2)
    end
  end

  describe '#show' do
    before do
      login_as(user)
    end

    it 'should allow the requester to see it' do
      proposal = FactoryGirl.create(:proposal, requester: user)
      get :show, id: proposal.id
      expect(response).not_to redirect_to("/proposals/")
      expect(flash[:alert]).not_to be_present
    end

    it 'should redirect random users' do
      proposal = FactoryGirl.create(:proposal, requester: FactoryGirl.create(:user))
      get :show, id: proposal.id
      expect(response).to redirect_to(proposals_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe '#approve' do
    it "signs the user in via the token" do
      proposal = FactoryGirl.create(:proposal, :with_approver, :with_cart)
      approval = proposal.approvals.first
      token = approval.create_api_token!

      post :approve, id: proposal.id, cch: token.access_token

      expect(controller.send(:current_user)).to eq(approval.user)
    end
  end
end
