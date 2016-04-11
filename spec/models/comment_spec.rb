describe Comment do
  describe "#create_without_callback" do
    it "does not create observer" do
      proposal = create(:proposal)
      comment = proposal.comments.create_without_callback(comment_text: 'foo')
      expect(proposal.observers.count).to eq(0)
    end
  end
end
