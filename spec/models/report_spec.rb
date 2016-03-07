describe Report do
  it "#client_query" do
    query = { test_client_request: { "client_data.amount" => "<123" } }.to_json
    report = create(:report, query: query)
    expect(report.client_query.to_s).to eq "client_data.amount:<123"
  end

  it "#text_query" do
    report = create(:report, query: { text: "something" }.to_json)
    expect(report.text_query).to eq "something"
  end

  it "#query_string" do
    query = { text: "something", test_client_request: { "client_data.amount" => "<123" } }.to_json
    report = create(:report, query: query)
    expect(report.query_string).to eq "(something) AND (client_data.amount:<123)"
  end

  it "#humanized_query" do
    query = { humanized: "(something) AND (Amount:<123)" }.to_json
    report = create(:report, query: query)
    expect(report.humanized_query).to eq "(something) AND (Amount:<123)"
  end

  it "#url" do
    report = create(:report)
    expect(report.url).to include "report=#{report.id}"
  end

  it "#for_user" do
    report = create(:report)
    expect(Report.for_user(report.user)).to eq [report]
  end

  it "#sql_for_user" do
    user = create(:user, client_slug: "test")
    expect(Report.sql_for_user(user)).to include "WHERE client_slug='#{user.client_slug}'"
  end

  it "#run", :elasticsearch do
    owner = create(:user, client_slug: "test")
    report = create(:report, query: { text: "something" }.to_json, user: owner)
    proposals = 3.times.map do |i|
      tcr = create(:test_client_request, project_title: "something #{i}")
      tcr.proposal.update(requester: owner)
      tcr.proposal.reindex
      tcr.proposal
    end
    Proposal.__elasticsearch__.refresh_index!

    proposal_data = report.run

    expect(proposal_data.rows.map(&:id)).to match_array(proposals.map(&:id))
  end
end
