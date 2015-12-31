describe "reports" do
  before do
    login_as(user)
  end

  it "provides Save as Report button on search results page", :js do
    proposals = populate_proposals

    visit query_proposals_path(text: proposals.first.name)

    click_on "Save as Report"
    fill_in "saved-search-name", with: "my test report"
    click_on "Save"

    expect(page).to have_content("Saved as report my test report") 
  end

  def user
    @_user ||= create(:user, client_slug: "test")
  end

  def populate_proposals
    proposals = 2.times.map do |i|
      wo = create(:test_client_request, project_title: "Work Order #{i}")
      wo.proposal.update(requester: user)
      wo.proposal.reindex
      wo.proposal
    end
    Proposal.__elasticsearch__.refresh_index!
    proposals
  end
end
