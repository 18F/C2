describe "observers" do
  it "allows observers to be added" do
    expect(CommunicartMailer).to receive_message_chain(:on_observer_added, :deliver_later)

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

  it "allows a user to add a reason when adding an observer" do
    reason = "is the archbishop of banterbury"
    proposal = FactoryGirl.create(:proposal)
    observer = FactoryGirl.create(:user)
    login_as(proposal.requester)

    visit "/proposals/#{proposal.id}"
    select observer.email_address, from: 'observation_user_email_address'
    fill_in "observation_reason", with: reason
    click_on 'Add an Observer'

    expect(page).to have_content("#{observer.full_name} has been added as an observer")
    proposal.reload

    expect(deliveries.first.body.encoded).to include reason   # comment notification
    expect(deliveries.second.body.encoded).to include reason  # subscription notification
  end
end
