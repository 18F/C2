describe "White House Service Center proposals" do
  it "saves a Cart with the attributes" do
    visit '/whsc/proposals/new'
    fill_in 'Description', with: "buying stuff"
    fill_in 'Vendor', with: 'ACME'
    fill_in 'Amount', with: '123'

    expect {
      click_on 'Submit for approval'
    }.to change { Cart.count }.from(0).to(1)
  end
end
