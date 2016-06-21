describe ClientSummary do
  it "counts non-canceled proposals" do
    summary = ClientSummary.new(2016, "Test")
    summary.add_status("pending")
    summary.add_status("canceled")
    expect(summary.status(:pending)).to eq(1)
    expect(summary.status(:canceled)).to eq(1)
    expect(summary.status(:completed)).to eq(0)
    expect(summary.status_sum).to eq(1)
  end

  it "sums totals for non-canceled proposals" do
    summary = ClientSummary.new(2016, "Test")
    pending_sub = 123
    canceled_sub = 456
    completed_sub = 385
    summary.add_subtotal("pending", pending_sub)
    summary.add_subtotal("canceled", canceled_sub)
    summary.add_subtotal("completed", completed_sub)
    expect(summary.subtotal(:pending)).to eq(pending_sub)
    expect(summary.subtotal(:canceled)).to eq(canceled_sub)
    expect(summary.subtotal(:completed)).to eq(completed_sub)
    expect(summary.total).to eq(pending_sub + completed_sub)
  end

  it "calculates percentages" do
    summary = ClientSummary.new(2016, "Test")
    summary.add_status("pending")
    summary.add_status("canceled")
    summary.add_subtotal("pending", 123)
    summary.add_subtotal("canceled", 456)
    expect(summary.status_percent(:pending)).to eq(50)
    expect(summary.status_percent(:canceled)).to eq(50)
    expect(summary.subtotal_percent(:pending)).to be_within(0.001).of(21.243)
    expect(summary.subtotal_percent(:canceled)).to be_within(0.001).of(78.756)
  end
end
