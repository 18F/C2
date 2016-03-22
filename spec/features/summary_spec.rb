describe "Summary page" do
  it "lists all subtotals correctly" do
    admin_user = create(:user, :admin, client_slug: 'ncr')
    status_counts = { pending: 3, canceled: 2, completed: 4 }
    create_proposals(status_counts)
    login_as(admin_user)
    @page = SummaryPage.new
    @page.load

    @page.tables[0].rows.each do |row|
      status_count = row.status_count.text.to_i
      status = row.status.text.downcase.to_sym
      expect(status_count).to eq status_counts[status]
    end
  end

  it "names the rows correctly" do
    admin_user = create(:user, :admin, client_slug: 'ncr')
    login_as(admin_user)
    @page = SummaryPage.new
    @page.load

    expect(@page.tables[0].rows.map(&:status).map(&:text).sort).to eq %w[Canceled Completed Pending]
  end
end


def create_proposals(status_counts)
  status_counts.each do |status, count|
    count.times do
      nwo = create(:ncr_work_order)
      nwo.proposal.update(status: status)
    end
  end
end
