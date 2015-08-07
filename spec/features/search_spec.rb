describe "searching" do
  let(:user){ FactoryGirl.create(:user) }
  let!(:approver){ FactoryGirl.create(:user) }

  before do
    login_as(user)
  end

  it "displays relevant results" do
    proposals = 2.times.map do |i|
      wo = FactoryGirl.create(:ncr_work_order, project_title: "Work Order #{i}")
      wo.proposal.update(requester: user)
      wo.proposal
    end
    visit '/proposals'
    fill_in 'text', with: proposals.first.name
    click_button 'Search'

    expect(current_path).to eq('/proposals/query')
    expect(page).to have_content(proposals.first.public_identifier)
    expect(page).not_to have_content(proposals.last.name)
  end

  it "populates the search box on the results page" do
    visit '/proposals'
    fill_in 'text', with: 'foo'
    click_button 'Search'

    expect(current_path).to eq('/proposals/query')
    field = find_field('text')
    expect(field.value).to eq('foo')
  end
end
