describe "observers" do
  it "allows observers to be added" do
    expect(CommunicartMailer).to receive(:on_observer_added).and_call_original

    work_order = FactoryGirl.create(:ncr_work_order)
    observer = FactoryGirl.create(:user)
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit "/proposals/#{proposal.id}"
    select observer.email_address, from: 'observation_user_email_address'
    click_on 'Add an Observer'

    expect(page).to have_content("#{observer.full_name} has been added as an observer")

    proposal.reload
    expect(proposal.observers).to eq [observer]
  end

  it "allows observers to be added by other observers" do
    proposal = FactoryGirl.create(:proposal, :with_observer)
    observer1 = proposal.observers.first
    login_as(observer1)

    observer2 = FactoryGirl.create(:user)

    visit "/proposals/#{proposal.id}"
    select observer2.email_address, from: 'observation_user_email_address'
    click_on 'Add an Observer'

    expect(page).to have_content("#{observer2.full_name} has been added as an observer")

    proposal.reload
    expect(proposal.observers.map(&:email_address)).to include(observer2.email_address)

    expect(email_recipients).to eq([observer2.email_address])
  end
end
