describe '/proposals/:id/history' do
  let(:user) { FactoryGirl.create(:user) }

  before do
    PaperTrail.whodunnit = user.id.to_s
  end

  it "displays the model information" do
    proposal = FactoryGirl.create(:proposal, requester: user)
    login_as(user)

    visit "/proposals/#{proposal.id}/history"

    expect(page).to have_content('Proposal')
  end
end
