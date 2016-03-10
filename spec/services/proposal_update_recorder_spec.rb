describe ProposalUpdateRecorder do
  describe "#run" do
    context "attribute changed" do
      it "adds a change comment" do
        description = "some text"
        work_order = create(:ncr_work_order, description: description)

        work_order.description = ""
        comment = ProposalUpdateRecorder.new(work_order, work_order.requester).run

        expect(comment).to be_update_comment
        expect(comment.comment_text).to eq("*Description* was changed from #{description} to *empty*")
      end
    end

    context "approving official value changed" do
      it "adds a change comment" do
        approver = create(:user)
        second_approver = create(:user)
        work_order = create(:ncr_work_order, approving_official: approver)
        work_order.approving_official = second_approver

        comment = ProposalUpdateRecorder.new(work_order, work_order.requester).run

        expect(comment).to be_update_comment
        expect(comment.comment_text).to eq(
          "*Approving official* was changed from #{approver.email_address} to #{second_approver.email_address}"
        )
      end
    end

    context "ncr organization changed" do
      it "adds a change comment" do
        org = create(:ncr_organization)
        second_org = create(:ncr_organization)
        work_order = create(:ncr_work_order, ncr_organization: org)
        work_order.ncr_organization = second_org

        comment = ProposalUpdateRecorder.new(work_order, work_order.requester).run

        expect(comment).to be_update_comment
        expect(comment.comment_text).to eq(
          "*Org code* was changed from #{org.code_and_name} to #{second_org.code_and_name}"
        )
      end
    end

    it "includes extra information if modified post approval" do
      work_order = create(:ncr_work_order)
      work_order.complete!
      work_order.vendor = "Mario Brothers"
      work_order.amount = 123.45

      comment = ProposalUpdateRecorder.new(work_order, work_order.requester).run

      expect(comment).to be_update_comment
      comment_text = "- *Vendor* was changed from Some Vend to Mario Brothers\n"
      comment_text += "- *Amount* was changed from $1,000.00 to $123.45\n"
      comment_text += "_Modified post-approval_"
      expect(comment.comment_text).to eq(comment_text)
    end

    it "does not add a change comment when nothing has changed" do
      work_order = create(:ncr_work_order, description: "")

      work_order.description = ""
      comment = ProposalUpdateRecorder.new(work_order, work_order.requester).run

      expect(comment).to be_nil
    end

    it "attributes the update comment to the user passed in" do
      work_order = create(:ncr_work_order, vendor: "old")
      modifier = create(:user, client_slug: "ncr")

      work_order.vendor = "VenVenVen"
      comment = ProposalUpdateRecorder.new(work_order, modifier).run

      expect(comment.user).to eq(modifier)
    end

    it "does not send a comment email for the update comment to proposal listeners" do
      work_order = create(:ncr_work_order, vendor: "old")
      listener = create(:user, client_slug: "ncr")
      work_order.proposal.add_observer(listener)

      work_order.vendor = "VenVenVen"

      expect {
        ProposalUpdateRecorder.new(work_order, work_order.requester).run
      }.to change { deliveries.length }.by(0)
    end
  end
end
