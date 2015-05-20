describe "redirecting from carts" do
  let!(:cart) { FactoryGirl.create(:cart) }
  let(:proposal) { cart.proposal }

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
      cart.update_attribute(:id, proposal.id + 1)  # distinct id from proposal
      visit "/carts/#{cart.id}"
      expect(current_path).to eq(proposal_path(proposal))
    end
  end
end
