describe "Pending Proposals filter" do
  let(:user) { create(:user) }
  let!(:proposals) { 4.times.map { create(:proposal) } }
  let!(:reviewable_proposals) { 4.times.map { create(:proposal, approver: user) } }
  let!(:cancelled) { 2.times.map { create(:proposal, status: 'cancelled') } }
  before :each do
    Proposal.all().each { |p| p.add_observer(user.email_address) }
    login_as(user)
  end

  def tables
    page.all('.tabular-data')
  end

  context 'home page' do
    it 'filters pending proposals according to current_user' do
      visit '/proposals'
      expect(tables.size).to eq(3) # pending_review, pending, cancelled
      expect(tables[0].text).to have_content('Please review')
      expect(tables[1].text).to have_content('Waiting for review')
      expect(tables[2].text).to have_content('Cancelled')
    end
  end
end
