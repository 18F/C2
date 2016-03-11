describe Searchable do
  describe ".rebuild_index" do
    it "should rebuild the index", elasticsearch: true do
      create(:proposal)

      expect {
        Proposal.rebuild_index
      }.not_to raise_error
    end
  end
end
