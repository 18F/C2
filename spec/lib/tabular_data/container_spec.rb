describe TabularData::Container do
  describe '#initialize' do
    it 'sets the columns' do
      config = {engine: 'Proposal',
                column_configs: {a: true, b: true, c: true},
                columns: ['a', 'b', 'c']}
      container = TabularData::Container.new(:a_name, config)
      expect(container.columns.length).to eq(3)
      expect(container.columns.map(&:name)).to eq(['a', 'b', 'c'])
    end

    it 'does not modify the query if there are no joins' do
      container = TabularData::Container.new(:a_name, engine: 'Proposal')
      expect(container.rows.to_sql).to eq(Proposal.all().to_sql)
    end

    it 'aliases direct joins' do
      container = TabularData::Container.new(:a_name, engine: 'Proposal', joins: {requester: true})
      expect(container.rows.to_sql).to include('ON "requester"."id" = "proposals"."requester_id"')
      container.rows.count  # smoke test
    end

    it 'aliases indirect joins' do
      container = TabularData::Container.new(:a_name, engine: 'ApiToken', joins: {approval: true, user: true})
      expect(container.rows.to_sql).to include('ON "user"."id" = "approvals"."user_id"')

      container.rows.count  # smoke test
    end
  end

  describe '#alter_query' do
    it 'allows the query to be modified' do
      pending = FactoryGirl.create(:proposal)
      approved = FactoryGirl.create(:proposal, status: 'approved')
      container = TabularData::Container.new(:name, engine: 'Proposal')

      expect(container.rows).to include(pending)
      expect(container.rows).to include(approved)

      container.alter_query { |p| p.closed }

      expect(container.rows).not_to include(pending)
      expect(container.rows).to include(approved)
    end
  end

  describe '#set_state_from_params' do
    let(:container) { 
      config = {engine: 'Proposal',
                column_configs: {id: true, client: {virtual: true}},
                columns: ['id', 'client']}
      TabularData::Container.new(:abc, config)
    }
    let!(:ncr) { FactoryGirl.create(:ncr_work_order).proposal }
    let!(:gsa18f) { FactoryGirl.create(:gsa18f_procurement).proposal }
    let!(:default) { FactoryGirl.create(:proposal) }

    it 'sets sort state if the field is valid' do
      container.set_state_from_params(ActionController::Parameters.new(tables: {abc: {sort: "id"}}))
      expect(container.rows.to_a).to eq([ncr, gsa18f, default])

      container.set_state_from_params(ActionController::Parameters.new(tables: {abc: {sort: "-id"}}))
      expect(container.rows.to_a).to eq([default, gsa18f, ncr])
    end

    it 'ignores invalid sorts' do
      invalids = [{tables: {abc: {sort: "client"}}},
                  {tables: {abc: {sort: "asdasd"}}},
                  {tables: {abc: "aaaa"}},
                  {other: 2}]
      invalids.each do |invalid|
        container.set_state_from_params(ActionController::Parameters.new(invalid))
        expect(container.rows.length).to eq(3)
      end
    end
  end
end
