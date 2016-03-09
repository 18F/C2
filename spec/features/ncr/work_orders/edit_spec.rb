feature "Editing NCR work order" do
  scenario "current user is not the requester, approver, or observer" do
    work_order = create(:ncr_work_order)
    stranger = create(:user, client_slug: "ncr")
    login_as(stranger)

    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(current_path).to eq("/ncr/work_orders/new")
    expect(page).to have_content("You must be the requester, approver, or observer")
  end
end
