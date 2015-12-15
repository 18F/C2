describe Query::Proposal::Listing do
  let(:params) { ActionController::Parameters.new }
  let(:user) { create(:user) }

  describe "when the user is a requester" do
    [:pending, :approved, :cancelled].each do |status|
      describe "##{status}" do
        it "ignores app admin role and only returns the user's Proposals" do
          create(:proposal, status: status)
          proposal = create(:proposal, requester: user, status: status)
          user.add_role('admin')
          listing = Query::Proposal::Listing.new(user, params)
          expect(listing.send(status).rows).to eq([proposal])
        end

        context "with an arbitrary client" do
          before do
            user.update_attribute(:client_slug, "ncr")
            user.add_role('client_admin')
          end

          it "ignores client_admin role and only displays the user's Proposals" do
            proposal = create(:proposal, requester: user, status: status)

            other_proposal = create(:proposal, status: status)
            create(:ncr_work_order, proposal: other_proposal)

            listing = Query::Proposal::Listing.new(user, params)
            expect(listing.send(status).rows).to eq([proposal])
          end
        end
      end
    end
  end

  describe "#pending_review" do
    context "when the user is an approver" do
      context "and the current waiting step lists you as user" do
        it "returns the proposal" do
          proposal = create(:proposal, :with_approver)
          user = proposal.individual_steps.first.user

          proposals = Query::Proposal::Listing.new(user, params).pending_review

          expect(proposals.rows).to eq([proposal])
        end
      end

      context "and you have already approved the proposal, but it is not complete" do
        it "does not return the proposal" do
          proposal = create(:proposal, :with_serial_approvers)
          first_step = proposal.individual_steps.first
          first_step.approve!

          proposals = Query::Proposal::Listing.new(first_step.user, params).pending_review

          expect(proposals.rows).to_not include(proposal)
        end
      end

      context "and the step listing you as user is not the current waiting step" do
        it "does not return the proposal" do
          proposal = create(:proposal, :with_serial_approvers)
          user = proposal.individual_steps.second.user

          proposals = Query::Proposal::Listing.new(user, params).pending_review

          expect(proposals.rows).to_not include(proposal)
        end
      end
    end

    context "when the user is a purchaser" do
      context "and the current waiting step lists you as purchaser" do
        it "returns the proposal" do
          proposal = create(:proposal, :with_approval_and_purchase)
          proposal.individual_steps.first.approve!
          user = proposal.individual_steps.second.user

          proposals = Query::Proposal::Listing.new(user, params).pending_review

          expect(proposals.rows).to eq([proposal])
        end
      end
    end
  end
end
