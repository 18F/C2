describe RolesConversion do
  it "runs as idempotent" do
    expect {
      RolesConversion.new.ncr_budget_approvers
      RolesConversion.new.gsa18f_approvers
    }.to change { User.count(0) }.by(0)
  end
end
