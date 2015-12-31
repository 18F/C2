describe Report do
  it "#client_query" do
    report = create(:report)
    expect(report.client_query.to_s).to eq "client_data.amount:<123"
  end

  it "#text_query" do
    report = create(:report)
    expect(report.text_query).to eq "something"
  end

  it "#query_string" do
    report = create(:report)
    expect(report.query_string).to eq "(something) AND (client_data.amount:<123)"
  end

  it "#humanized_query" do
    report = create(:report)
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
end
