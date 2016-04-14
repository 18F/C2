describe HistoryList do
  describe 'contents' do
    it "limits to the specified Proposal" do
      prop1 = create(:proposal)
      _prop2 = create(:proposal)

      query = HistoryList.new(prop1).container.query
      expect(query).to eq(prop1.versions.reverse)
    end
  end
end
