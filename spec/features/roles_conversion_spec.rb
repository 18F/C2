describe "RolesConversion" do
  it "should create only one User-per-role-per-slug" do
    user = RolesConversion.with_email_role_slug!('someone@example.gov', 'foo', 'ncr')
    expect(user.email_address).to eq('someone@example.gov')
    user2 = RolesConversion.with_email_role_slug!('someoneelse@example.gov', 'foo', 'ncr')
    expect(user2).to be_nil
  end

  it "should convert NCR budget approvers" do
    expect(User.count).to eq(2) # via db/seeds
    RolesConversion.ncr_budget_approvers
    expect(User.count).to eq(2) # no change (idempotent)
  end
end
