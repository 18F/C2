describe TabularData::Column do
  describe '#initialize' do
    context '@header' do
      it 'uses the specified header, if present' do
        col = TabularData::Column.new('aaa', 'proposals.aaa', header: 'bbb')
        expect(col.header).to eq 'bbb'
      end

      it 'falls back to the titleized column name' do
        col = TabularData::Column.new('aaa_bbb', 'proposals.aaa_bbb')
        expect(col.header).to eq 'Aaa Bbb'
      end
    end

    context '@formatter' do
      it 'uses the specified formatter, if present' do
        col = TabularData::Column.new('aaa', 'proposals.aaa', formatter: :my_format)
        expect(col.formatter). to eq :my_format
      end

      it 'falls back to :none' do
        col = TabularData::Column.new('aaa', 'proposals.aaa')
        expect(col.formatter). to eq :none
      end
    end
  end

  describe '#can_sort?' do
    it 'prevents virtual fields from being sorted' do
      col = TabularData::Column.new('aaa', 'proposals.aaa', virtual: true)
      expect(col.can_sort?).to be false
    end

    it 'allows other fields to be sorted' do
      col = TabularData::Column.new('aaa', 'proposals.aaa')
      expect(col.can_sort?).to be true
    end
  end

  describe '#sort' do
    let (:col) { TabularData::Column.new('aaa', 'proposals.aaa') }
    it 'starts with no sort' do
      expect(col.sort_dir).to be_nil
    end

    it 'allows ascending sort' do
      result = col.sort(:asc)
      expect(result.to_sql).to eq("(proposals.aaa) ASC")
      expect(col.sort_dir).to be :asc
    end

    it 'allows descending sort' do
      result = col.sort(:desc)
      expect(result.to_sql).to eq("(proposals.aaa) DESC")
      expect(col.sort_dir).to be :desc
    end
  end

  describe '#display' do
    let(:work_order) { FactoryGirl.create(:ncr_work_order) }

    it 'accesses fields directly (no display field)' do
      col = TabularData::Column.new(:expense_type, 'ncr_work_orders.expense_type')
      expect(col.display(work_order)).to eq(work_order.expense_type)
    end

    it 'accesses fields directly (display field overrides db)' do
      col = TabularData::Column.new(:expense_type, 'ncr_work_orders.expense_type', display: 'emergency')
      expect(col.display(work_order)).to eq(work_order.emergency)
    end

    it 'can read across objects' do
      col = TabularData::Column.new(:expense_type, 'ncr_work_orders.expense_type', display: 'proposal.requester.email_address')
      expect(col.display(work_order)).to eq(work_order.proposal.requester.email_address)
    end
  end
end
