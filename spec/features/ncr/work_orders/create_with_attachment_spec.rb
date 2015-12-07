feature "Create NCR work order with attachment" do
  scenario "allows attachments to be added during intake without JS" do
    login_as(requester)
    visit new_ncr_work_order_path

    expect(page).to have_content("Attachments")
    expect(page).not_to have_selector(".js-am-minus")
    expect(page).not_to have_selector(".js-am-plus")
    expect(page).to have_selector("input[type=file]", count: 10)
  end

  scenario "allows attachments to be added during intake with JS", :js do
    login_as(requester)
    visit new_ncr_work_order_path

    first_minus = find(".js-am-minus")
    first_plus = find(".js-am-plus")

    expect(page).to have_content("Attachments")
    expect(first_minus).to be_visible
    expect(first_plus).to be_visible
    expect(first_minus).to be_disabled
    expect(find("input[type=file]")[:name]).to eq("attachments[]")
    first_plus.click # Adds one row
    expect(page).to have_selector(".js-am-minus", count: 2)
    expect(page).to have_selector(".js-am-plus", count: 2)
    expect(page).to have_selector("input[type=file]", count: 2)
  end

  def requester
    @_requester ||= create(:user, client_slug: "ncr")
  end
end
