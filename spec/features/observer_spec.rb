describe "observers" do
  it "allows observers to be added" do
    work_order = FactoryGirl.create(:ncr_work_order)
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit "/proposals/#{proposal.id}/observations"
    fill_in 'observation[user][email_address]', with: 'observer@some-dot-gov.gov'
    click_on 'Add'

    expect(page).to have_content("observer@some-dot-gov.gov has been added as an observer")

    proposal.reload
    expect(proposal.observers.map(&:email_address)).to eq(['observer@some-dot-gov.gov'])
  end
end
