describe Searchable do
  describe ".rebuild_index" do
    it "should rebuild the index" do
      expect(Proposal.rebuild_index).not_to raise
    end
  end
end
