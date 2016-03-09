describe Searchable do
  describe ".rebuild_index" do
    it "should rebuild the index", elasticsearch: true do
      create(:proposal)

      expect(Proposal.rebuild_index).not_to raise
    end
  end
end
