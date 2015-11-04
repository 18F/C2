describe ProposalUpdateRecorder do
  describe "#run" do
    it "adds a change comment" do
      description = "some text"
      work_order = create(:ncr_work_order, description: description)

      work_order.description = ""
      ProposalUpdateRecorder.new(work_order).run

      comment = work_order.proposal.comments.last
      expect(comment).to be_update_comment
      expect(comment.comment_text).to eq("*Description* was changed from #{description} to *empty*")
    end

    it "includes extra information if modified post approval" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.vendor = "Mario Brothers"
      work_order.amount = 123.45

      ProposalUpdateRecorder.new(work_order).run
      comment = work_order.proposal.comments.last

      expect(comment).to be_update_comment
      comment_text = "- *Vendor* was changed from Some Vend to Mario Brothers\n"
      comment_text += "- *Amount* was changed from $1,000.00 to $123.45\n"
      comment_text += "_Modified post-approval_"
      expect(comment.comment_text).to eq(comment_text)
    end

    it "does not add a change comment when nothing has changed" do
      work_order = create(:ncr_work_order, description: "")

      work_order.description = ""
      ProposalUpdateRecorder.new(work_order).run

      comment = work_order.proposal.comments.last
      expect(comment).to be_nil
    end

    it "attributes the update comment to the requester by default" do
      work_order = create(:ncr_work_order, vendor: "old")

      work_order.vendor = "VenVenVen"
      ProposalUpdateRecorder.new(work_order).run

      comment = work_order.comments.update_comments.last
      expect(comment.user).to eq(work_order.requester)
    end

    it "attributes the update comment to someone set explicitly" do
      work_order = create(:ncr_work_order, vendor: "old")
      modifier = create(:user)
      work_order.modifier = modifier

      work_order.vendor = "VenVenVen"
      ProposalUpdateRecorder.new(work_order).run

      comment = work_order.comments.update_comments.last
      expect(comment.user).to eq(modifier)
    end

    it "does not send a comment email for the update comment to proposal listeners" do
      work_order = create(:ncr_work_order, vendor: "old")
      listener = create(:user)
      work_order.proposal.add_observer(listener)

      work_order.vendor = "VenVenVen"

      expect {
        ProposalUpdateRecorder.new(work_order).run
      }.to change { deliveries.length }.by(0)
    end
  end
end
