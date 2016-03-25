describe ProposalDecorator do
  describe "#detailed_status" do
    context "pending" do
      it "returns 'pending [next step type]'" do
        proposal = create(:proposal, status: "pending")
        create(:approval_step, status: "actionable", proposal: proposal)

        decorator = ProposalDecorator.new(proposal)

        expect(decorator.detailed_status).to eq "pending approval"

      end
    end

    context "canceled or completed" do
      it "returns regular status" do
        proposal = build(:proposal, status: "canceled")

        decorator = ProposalDecorator.new(proposal)

        expect(decorator.detailed_status).to eq "canceled"
      end
    end
  end
  describe "#total_price" do
    context "client data present" do
      it "returns total price from client data" do
        test_client_data = create(:test_client_request)
        proposal = create(:proposal, client_data: test_client_data)

        expect(proposal.decorate.total_price).to eq test_client_data.total_price
      end
    end

    context "no client data" do
      it "returns an empty string" do
        proposal = create(:proposal)

        expect(proposal.decorate.total_price).to eq ""
      end
    end
  end
  describe "#waiting_text_for_status_in_table" do
    context "when the proposal has an actionable step" do
      it "returns the correct text" do
        proposal = create(:proposal).decorate
        approval_step = double("Steps::Approval").as_null_object
        expect(proposal).to receive(:currently_awaiting_steps).and_return([approval_step])
        expect(approval_step).to receive(:waiting_text).and_return("blah")
        expect(proposal.waiting_text_for_status_in_table).to eq "blah"
      end
    end
    context "when the proposal does not have an actionable step" do
      it "returns the correct default text" do
        proposal = build_stubbed(:proposal).decorate
        expect(proposal.waiting_text_for_status_in_table).to eq "This proposal has no steps"
      end
    end
  end

  describe "#step_text_for_user" do
    context "when the active step is an approval" do
      it "fetches approval text" do
        proposal = create(:proposal).decorate
        user = create(:user)
        step = Steps::Approval.new(user: user)
        proposal.add_initial_steps([step])

        expect(proposal.step_text_for_user(:execute_button, user)).to eq "Approve"
      end
    end

    context "when the active step is a purchase" do
      it "fetches purchase text" do
        proposal = create(:proposal).decorate
        user = create(:user)
        step = Steps::Purchase.new(user: user)
        proposal.add_initial_steps([step])

        expect(proposal.step_text_for_user(:execute_button, user)).to eq "Mark as Purchased"
      end
    end
  end

  describe "#final_completed_date and #total_completion_days" do
    include ProposalSpecHelper

    context "when the proposal is complete" do
      it "returns completed_at date of last step" do
        proposal = create(:proposal, :with_serial_approvers).decorate
        fully_complete(proposal)
        proposal.complete!
        proposal.reload
        proposal.created_at = 2.days.ago

        expect(proposal.final_completed_date).to eq(proposal.individual_steps.last.completed_at)
        expect(proposal.total_completion_days).to eq(2)
      end

      it "returns empty string when no steps are defined" do
        proposal = create(:proposal).decorate
        proposal.complete!

        expect(proposal.final_completed_date).to eq("")
        expect(proposal.total_completion_days).to eq("")
      end
    end

    context "when the proposal is not complete" do
      it "returns empty string for final_completed_date and total_completion_days" do
        proposal = create(:proposal, :with_serial_approvers).decorate
        proposal.created_at = 2.days.ago

        expect(proposal.final_completed_date).to eq("")
        expect(proposal.total_completion_days).to eq("")
      end
    end
  end

  describe "#final_step_label" do
    context "purchase step" do
      it "looks like a Purchase" do
        proposal = create(:proposal, :with_approval_and_purchase).decorate

        expect(proposal.final_step_label).to eq("Final Purchase Completed")
      end
    end

    context "approval step" do
      it "looks like an Approval" do
        proposal = create(:proposal, :with_serial_approvers).decorate

        expect(proposal.final_step_label).to eq("Final Approval Completed")
      end
    end

    context "no step" do
      it "uses generic label" do
        proposal = create(:proposal).decorate

        expect(proposal.final_step_label).to eq("Final Step Completed")
      end
    end
  end
end
