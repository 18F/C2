describe "searching" do
  let(:user){ FactoryGirl.create(:user) }

  before do
    login_as(user)
  end

  it "displays relevant results" do
    proposals = 2.times.map do |i|
      proposal = FactoryGirl.create(:proposal, requester: user)
      FactoryGirl.create(:ncr_work_order, project_title: "Work Order #{i}", proposal: proposal)
      proposal
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

  it "finds results based on public id" do 
    visit '/ncr/work_orders/new'
    fill_in 'Project title', with: "buying stuff"
    fill_in 'Description', with: "desc content"
    choose 'BA80'
    fill_in 'RWA Number', with: 'F1234567'
    fill_in 'Vendor', with: 'ACME'
    fill_in 'Amount', with: 123.45
    check "I am going to be using direct pay for this transaction"
    fill_in "Approving official's email address", with: 'approver@example.com'
    fill_in 'Building number', with: Ncr::Building.first
    select Ncr::Organization.all[0], :from => 'ncr_work_order_org_code'
    click_on 'Submit for approval'

    proposal = Proposal.last
    visit "/proposals/query?text=#{proposal.public_id}"
    expect(page).to have_content(proposal.public_id)
  end
end
