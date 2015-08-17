describe "observers" do
  it "allows observers to be added" do
    work_order = FactoryGirl.create(:ncr_work_order)
    observer = FactoryGirl.create(:user)
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit "/proposals/#{proposal.id}"
    select observer.email_address, from: 'observation_user_email_address'
    click_on 'Add a Subscriber'

    expect(page).to have_content("#{observer.full_name} has been added as an observer")

    proposal.reload
    expect(proposal.observers).to eq [observer]

    expect(email_recipients).to eq([observer.email_address])
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
