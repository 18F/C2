describe 'View history for a proposal' do
  let(:user) { FactoryGirl.create(:user) }

  it "displays the model information" do
    PaperTrail.whodunnit = user.id.to_s
    proposal = FactoryGirl.create(:proposal, requester: user)
    login_as(user)

    visit history_proposal_path(proposal)

    expect(page).to have_content('Proposal')
  end
end
