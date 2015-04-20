describe "redirecting from carts" do
  let(:proposal) {
    FactoryGirl.create(:proposal, :with_requester, :with_approvers, :with_cart)}
  before do
    login_as(proposal.requester)
  end

  describe '#index' do
    it 'forwards' do
      visit "/carts"
      expect(current_path).to eq(proposals_path)
    end
  end

  describe '#archive' do
    it 'forwards' do
      visit "/carts/archive"
      expect(current_path).to eq('/proposals/archive')
    end
  end

  describe '#show' do
    it 'forwards' do
      proposal.cart.update_attribute(:id, -11)  # distinct id from proposal
      visit "/carts/" + proposal.cart.id.to_s
      expect(current_path).to eq(proposal_path(proposal))
    end
  end
end
