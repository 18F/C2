describe Query::Proposal::FieldedSearch do
  it "#to_s" do
    fs = Query::Proposal::FieldedSearch.new({
      foo: "bar"
    })
    expect(fs.to_s).to eq "foo:(bar)"
  end
  it "skips wildcard-only fields" do
    fs = Query::Proposal::FieldedSearch.new({
      foo: "bar",
      color: "*"
    })
    expect(fs.to_s).to eq "foo:(bar)"
  end
  it "#present?" do
    fs = Query::Proposal::FieldedSearch.new(nil)
    expect(fs.present?).to eq false
  end
  it "respects advanced value syntax" do
    fs = Query::Proposal::FieldedSearch.new({
      amount: ">100"
    })
    expect(fs.to_s).to eq "amount:>100"
  end
  it "#to_h" do
    fs = Query::Proposal::FieldedSearch.new({
      wild: "*",
      foo: "",
      bar: nil,
      bool: false,
      color: "green"
    })
    expect(fs.to_h).to eq( { color: "green" } )
  end
end
