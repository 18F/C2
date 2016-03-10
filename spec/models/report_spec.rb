describe Report do
  describe "#client_query" do
    it "stringifies client_query hash" do
      query = { test_client_request: { "client_data.amount" => "<123" } }.to_json
      report = create(:report, query: query)
      expect(report.client_query.to_s).to eq "client_data.amount:<123"
    end
  end

  describe "#text_query" do
    it "stringifies text query" do
      report = create(:report, query: { text: "something" }.to_json)
      expect(report.text_query).to eq "something"
    end
  end

  describe "#query_string" do
    it "concats client and text queries" do
      query = { text: "something", test_client_request: { "client_data.amount" => "<123" } }.to_json
      report = create(:report, query: query)
      expect(report.query_string).to eq "(something) AND (client_data.amount:<123)"
    end
  end

  describe "#humanized_query" do
    it "humanizes all field names" do
      query = { humanized: "(something) AND (Amount:<123)" }.to_json
      report = create(:report, query: query)
      expect(report.humanized_query).to eq "(something) AND (Amount:<123)"
    end
  end

  describe "#url" do
    it "construct the search URL for a report" do
      report = create(:report)
      expect(report.url).to include "report=#{report.id}"
    end
  end

  describe "#for_user" do
    it "associates owner for a report" do
      report = create(:report)
      expect(Report.for_user(report.user)).to eq [report]
    end
  end

  describe "#sql_for_user" do
    it "constructs SQL for finding all reports to which a user has access" do
      user = create(:user, client_slug: "test")
      expect(Report.sql_for_user(user)).to include "WHERE client_slug='#{user.client_slug}'"
    end
  end

  describe "#run", :elasticsearch do
    it "executes search query the Report represents" do
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

  describe "#subscriptions" do
    it "identifies related scheduled reports" do
      owner = create(:user, client_slug: "test")
      report = create(:report, query: { text: "something" }.to_json, user: owner)
      scheduled_report = create(:scheduled_report, frequency: "daily", user: owner, report: report)

      expect(report.subscribed?(owner)).to eq(true)
      expect(report.subscription_for(owner)).to eq([scheduled_report])
    end
  end
end
