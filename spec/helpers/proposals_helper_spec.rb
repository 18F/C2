describe ProposalsHelper do
  describe '#datespan_helper' do
    it 'has a nice header for month spans' do
      start_date = Date.new(2012, 6, 1)
      end_date = Date.new(2012, 7, 1)
      expect(helper.datespan_header(start_date, end_date)).to eq('(Jun 2012)')
    end

    it 'has a generic header for other dates' do
      start_date = Date.new(2012, 6, 2)
      end_date = Date.new(2012, 7, 2)
      expect(helper.datespan_header(start_date, end_date)).to eq('(2012-06-02 - 2012-07-02)')
    end
  end
end
