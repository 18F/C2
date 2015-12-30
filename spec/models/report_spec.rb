describe Report do
  it "parses default factory query" do
    report = create(:report)
    expect(report.client_query.to_s).to eq "client_data.amount:<123"
    expect(report.text_query).to eq "something"
    expect(report.query_string).to eq "(something) AND (client_data.amount:<123)"
    expect(report.humanized_query).to eq "(something) AND (Amount:<123)"
  end
end
