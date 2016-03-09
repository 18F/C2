feature "Testing with PhantomJS" do
  scenario "lacks client-side HTML5 form validation", :js do
    ncr_user = create(:user, client_slug: "ncr")
    login_as(ncr_user)
    visit new_ncr_work_order_path
    fill_in "Project title", with: "buying stuff"
    choose "BA60"
    find("input[aria-label='Building number']").native.send_keys("BillDing")
    find("input[aria-label='Vendor']").native.send_keys("ACME")
    fill_in "Amount", with: "123"
    click_on "Submit for approval"
    # if validation worked, the path would stay at new_ncr_work_order_path
    expect(current_path).to eq(ncr_work_orders_path)
  end
end
