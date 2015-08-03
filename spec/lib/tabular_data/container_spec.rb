describe TabularData::Container do
  describe '#initialize' do
    it 'sets the columns' do
      container = TabularData::Container.new(:a_name, engine: 'Proposal', columns: [{db_field: 'a'}, {db_field: 'b'}, {db_field: 'c'}])
      expect(container.columns.length).to eq(3)
      expect(container.columns.map(&:name)).to eq(['a', 'b', 'c'])
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
    let(:container) { TabularData::Container.new(:abc, engine: 'Proposal', columns: [{db_field: 'id'}, {display_field: 'client'}]) }
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
