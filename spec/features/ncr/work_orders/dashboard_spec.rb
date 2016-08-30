describe "viewing NCR Dashboard" do
  let(:work_order)   { create(:ncr_work_order) }
  let(:ncr_proposal) { work_order.proposal }

  before do
    work_order.setup_approvals_and_observers
    login_as(work_order.requester)
  end

  it "allows you to download a CSV of work orders", :js do
    visit "/ncr/dashboard"
    year = Date.today.year
    click_on(year)
    click_on("Download")
    expect(current_path).to eq '/proposals/query'
  end
end