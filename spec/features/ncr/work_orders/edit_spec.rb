feature 'Editing NCR work orders' do
  around(:each) do |example|
    with_env_var('DISABLE_SANDBOX_WARNING', 'true') do
      example.run
    end
  end

  let(:work_order) { create(:ncr_work_order, description: 'test') }

  scenario 'current user is not the requester, approver, or observer' do
    stranger = create(:user, client_slug: "ncr")
    login_as(stranger)

    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(current_path).to eq("/ncr/work_orders/new")
    expect(page).to have_content("You must be the requester, approver, or observer")
  end
end
