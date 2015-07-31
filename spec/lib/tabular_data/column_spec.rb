describe TabularData::Column do
  describe '#initialize' do
    let (:arel) { TabularData::ArelTables.new(Proposal) }

    context '@name' do
      it 'uses db_field' do
        col = TabularData::Column.new(arel, db_field: 'aaa.bbb')
        expect(col.name).to eq 'aaa.bbb'
      end

      it 'falls back to display_field' do
        col = TabularData::Column.new(arel, display_field: 'aaa.bbb')
        expect(col.name).to eq 'aaa.bbb'
      end

      it 'prefers db_field' do
        col = TabularData::Column.new(arel, db_field: 'aaa.aaa', display_field: 'bbb.bbb')
        expect(col.name).to eq 'aaa.aaa'
      end
    end

    context '@header' do
      it 'uses the specified header, if present' do
        col = TabularData::Column.new(arel, db_field: 'aaa', header: 'BBB')
        expect(col.header). to eq 'BBB'
      end

      it 'falls back to the column name' do
        col = TabularData::Column.new(arel, db_field: 'aaa')
        expect(col.header). to eq 'aaa'
      end
    end

    context '@formatter' do
      it 'uses the specified formatter, if present' do
        col = TabularData::Column.new(arel, formatter: :my_format)
        expect(col.formatter). to eq :my_format
      end

      it 'falls back to :none' do
        col = TabularData::Column.new(arel, {})
        expect(col.formatter). to eq :none
      end
    end

    context '@arel_col' do
      it 'is set when a db_field is present' do
        col = TabularData::Column.new(arel, db_field: "aaa")
        expect(col.arel_col).not_to be_nil
        expect(col.arel_col).to eq(arel.col("aaa"))
      end

      it 'will not be set if there is no db_field' do
        col = TabularData::Column.new(arel, display_field: "aaa")
        expect(col.arel_col).to be_nil
      end
    end
  end

  describe '#display_value' do
    let (:arel) { TabularData::ArelTables.new(Ncr::WorkOrder) }
    let(:work_order) { FactoryGirl.create(:ncr_work_order) }

    it 'accesses fields directly (no display field)' do
      col = TabularData::Column.new(arel, db_field: 'expense_type')
      expect(col.display_value(work_order)).to eq(work_order.expense_type)
    end

    it 'accesses fields directly (display field overrides db)' do
      col = TabularData::Column.new(arel, db_field: 'expense_type', display_field: 'emergency')
      expect(col.display_value(work_order)).to eq(work_order.emergency)
    end

    it 'can read across objects' do
      col = TabularData::Column.new(arel, display_field: 'proposal.requester.email_address')
      expect(col.display_value(work_order)).to eq(work_order.proposal.requester.email_address)
    end
  end
end
