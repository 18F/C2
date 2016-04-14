describe HistoryList do
  describe 'contents' do
    it "First event in history should be create" do
      prop1 = create(:proposal)

      history = HistoryList.new(prop1)
      first_event = history.events.first.event
      expect(first_event).to eq("create")
    end
  end
end
