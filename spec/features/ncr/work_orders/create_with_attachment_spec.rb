feature "Create NCR work order with attachment" do
  scenario "allows attachments to be added during intake without JS" do
    requester = create(:user, client_slug: "ncr")
    login_as(requester)
    visit new_ncr_work_order_path

    expect(page).to have_content("Attachments")
    expect(page).not_to have_selector(".js-am-minus")
    expect(page).not_to have_selector(".js-am-plus")
    expect(page).to have_selector(".attachment-label", count: 10)
  end

  scenario "allows attachments to be added during intake with JS", :js do
    requester = create(:user, client_slug: "ncr")
    login_as(requester)
    visit new_ncr_work_order_path

    first_minus = find(".js-am-minus")
    first_plus = find(".js-am-plus")

    expect(page).to have_content("Attachments")
    expect(first_minus).to be_visible
    expect(first_plus).to be_visible
    expect(first_minus).to be_disabled
    show_attachment_buttons
    expect(find("input[type=file]")[:name]).to eq("attachments[]")
    first_plus.click # Adds one row
    show_attachment_buttons
    expect(page).to have_selector(".js-am-minus", count: 2)
    expect(page).to have_selector(".js-am-plus", count: 2)
    expect(page).to have_selector("input[type=file]", count: 2)
  end
end

def show_attachment_buttons
    execute_script("$('input[type=file]').show()")
end
