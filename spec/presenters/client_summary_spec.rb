describe ClientSummary do
  it "adds status" do
    summary = ClientSummary.new(2016, "Test")
    summary.add_status("pending")
    summary.add_status("cancelled")
    expect(summary.status(:pending)).to eq(1)
    expect(summary.status(:cancelled)).to eq(1)
    expect(summary.status(:approved)).to eq(0)
    expect(summary.status_sum).to eq(2)
  end

  it "adds totals" do
    summary = ClientSummary.new(2016, "Test")
    summary.add_subtotal("pending", 123)
    summary.add_subtotal("cancelled", 456)
    expect(summary.subtotal(:pending)).to eq(123)
    expect(summary.subtotal(:cancelled)).to eq(456)
    expect(summary.total).to eq(579)
  end

  it "calculates percentages" do
    summary = ClientSummary.new(2016, "Test")
    summary.add_status("pending")
    summary.add_status("cancelled")
    summary.add_subtotal("pending", 123)
    summary.add_subtotal("cancelled", 456)
    expect(summary.status_percent(:pending)).to eq(50)
    expect(summary.status_percent(:cancelled)).to eq(50)
    expect(summary.subtotal_percent(:pending)).to be_within(0.001).of(21.243)
    expect(summary.subtotal_percent(:cancelled)).to be_within(0.001).of(78.756)
  end
end
