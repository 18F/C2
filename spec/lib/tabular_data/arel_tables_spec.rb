describe TabularData::ArelTables do
  describe '#initialize' do
    it 'sets the base table' do
      arel = TabularData::ArelTables.new(User)
      expect(arel.col("example")).to eq(User.arel_table[:example])
    end
  end

  describe '#add_joins' do
    it 'does not modify the query if there are no joins' do
      arel = TabularData::ArelTables.new(User)
      expect(arel.add_joins(User.order(id: :desc), [])).to eq(User.order(id: :desc))
    end

    it 'adds references for direct joins' do
      arel = TabularData::ArelTables.new(Proposal)
      query = arel.add_joins(Proposal, {requester: true})

      expect(query.to_sql).to eq(Proposal.joins(:requester).to_sql)
      expect(arel.col("requester.email_address")).not_to be_nil
      expect(arel.col("aaaaa.bbbb")).to be_nil
    end

    it 'adds references for indirect joins' do
      arel = TabularData::ArelTables.new(ApiToken)
      query = arel.add_joins(ApiToken, {approval: true, user: true})

      expect(query.to_sql).to eq(ApiToken.joins(:approval, :user).to_sql)
      expect(arel.col("approval.status")).not_to be_nil
      expect(arel.col("user.email_address")).not_to be_nil
      expect(arel.col("aaaaa.bbbb")).to be_nil
    end
  end
end
