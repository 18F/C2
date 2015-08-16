describe "observers" do
  it "allows observers to be added" do
    work_order = FactoryGirl.create(:ncr_work_order)
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit "/proposals/#{proposal.id}/observations"
    fill_in 'Email address', with: 'observer@some-dot-gov.gov'
    click_on 'Add'

    expect(page).to have_content("observer@some-dot-gov.gov has been added as an observer")

    proposal.reload
    expect(proposal.observers.map(&:email_address)).to eq(['observer@some-dot-gov.gov'])

    expect(email_recipients).to eq(['observer@some-dot-gov.gov'])
  end

  it "doesn't allow observers to be added if not signed in" do
    visit '/proposals/1/observations'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  it "doesn't allow observers to be added if not involved in the Proposal" do
    proposal = FactoryGirl.create(:proposal)
    user = FactoryGirl.create(:user)
    login_as(user)

    visit "/proposals/#{proposal.id}/observations"

    expect(current_path).to eq('/proposals')
    expect(page).to have_content("not allowed")
  end

  it "allows observers to be added by other observers" do
    proposal = FactoryGirl.create(:proposal, :with_observer)
    observer = proposal.observers.first
    login_as(observer)

    visit "/proposals/#{proposal.id}/observations"
    fill_in 'Email address', with: 'observer@some-dot-gov.gov'
    click_on 'Add'

    expect(page).to have_content("observer@some-dot-gov.gov has been added as an observer")

    proposal.reload
    expect(proposal.observers.map(&:email_address)).to include('observer@some-dot-gov.gov')

    expect(email_recipients).to eq(['observer@some-dot-gov.gov'])
  end
end
