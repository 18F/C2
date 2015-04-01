describe "Version check" do
  let(:proposal) { FactoryGirl.create(:proposal, :with_approvers, :with_cart,
                                       :with_requester) }

  it "occurs if the cart is modified in after seeing the profile page" do
    login_as(proposal.approvals.first.user)
    visit "/carts/#{proposal.cart.id}"

    sleep 1.second  # wait to get a new update time
    proposal.cart.update_attribute(:name, 'Some other name')

    click_on 'Approve'

    expect(page).to have_content("This request has recently been changed.")
    expect(current_path).to eq("/carts/#{proposal.cart.id}")
  end
end
