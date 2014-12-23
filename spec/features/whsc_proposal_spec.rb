describe "White House Service Center proposals" do
  it "saves a Cart with the attributes" do
    visit '/whsc/proposals/new'
    fill_in 'Description', with: "buying stuff"
    fill_in 'Vendor', with: 'ACME'
    fill_in 'Amount', with: '123.45'

    expect {
      click_on 'Submit for approval'
    }.to change { Cart.count }.from(0).to(1)

    cart = Cart.last
    expect(cart.name).to eq("buying stuff")
    expect(cart.getProp(:vendor)).to eq('ACME')
    # TODO should this persist as a number?
    expect(cart.getProp(:amount)).to eq('123.45')
  end
end
