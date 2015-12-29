describe "searching" do
  let(:user){ create(:user, client_slug: "test") }
  let!(:approver){ create(:user) }

  before do
    login_as(user)
  end

  it "displays relevant results", :js do
    proposals = populate_proposals

    visit '/proposals'
    fill_in 'text', with: proposals.first.name
    click_button "search-button"

    expect(current_path).to eq('/proposals/query')
    expect(page).to have_content(proposals.first.public_id)
    expect(page).not_to have_content(proposals.last.name)
  end

  it "populates the search box on the results page", :js do
    visit '/proposals'
    fill_in 'text', with: 'foo'
    click_button "search-button"

    expect(current_path).to eq('/proposals/query')
    field = find_field('text')
    expect(field.value).to eq('foo')
  end

  it "does not show search UI for user without client_slug" do
    no_client_user = create(:user)
    login_as(no_client_user)

    visit proposals_path
    expect(page).not_to have_button("Search")
  end

  it "contains Download link to CSV", :js do
    proposals = populate_proposals

    visit proposals_path
    fill_in "text", with: proposals.first.name
    click_button "search-button"

    expect(page).to have_content("Download")
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
