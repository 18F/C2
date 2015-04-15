describe CartsController do
  let(:proposal) {
    FactoryGirl.create(:proposal, :with_requester, :with_approvers, :with_cart)}
  before do
    login_as(proposal.requester)
  end

  describe '#index' do
    it 'forwards' do
      get :index
      expect(response).to redirect_to(proposals_path)
    end
  end

  describe '#archive' do
    it 'forwards' do
      get :archive
      expect(response).to redirect_to('/proposals/archive')
    end
  end

  describe '#show' do
    it 'forwards' do
      proposal.cart.update_attribute(:id, -11)  # distinct id from proposal
      get :show, id: proposal.cart.id
      expect(response).to redirect_to(proposal_path(proposal))
    end
  end
end
