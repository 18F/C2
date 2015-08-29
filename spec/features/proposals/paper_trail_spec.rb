describe '/proposals/:id/paper_trail' do
  let(:user) { FactoryGirl.create(:user) }

  before do
    PaperTrail.whodunnit = user.id.to_s
  end

  it "displays the model information" do
    proposal = FactoryGirl.create(:proposal, requester: user)
    login_as(user)

    visit "/proposals/#{proposal.id}/paper_trail"

    expect(page).to have_content('Proposal')
  end
end
