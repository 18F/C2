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
end
