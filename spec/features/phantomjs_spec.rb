feature "Testing with PhantomJS" do
  scenario "lacks client-side HTML5 form validation", :js do
    ncr_user = create(:user, client_slug: "ncr")
    login_as(ncr_user)
    visit new_ncr_work_order_path
    fill_in "Project title", with: "buying stuff"
    choose "BA60"
    fill_in_selectized("ncr_work_order_building_number", "BillDing")
    fill_in_selectized("ncr_work_order_vendor", "ACME")
    fill_in "Amount", with: "123"
    click_on "SUBMIT"
    # if validation worked, the path would stay at new_ncr_work_order_path
    expect(current_path).to eq(ncr_work_orders_path)
  end
end
