describe StepMailer do
  include MailerSpecHelper

  before(:all) { ENV["DISABLE_EMAIL"] = nil }
  after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }

  describe "#step_user_reply" do
    let(:mail) { StepMailer.step_reply_received(approval) }

    before do
      approval.complete!
    end

    it_behaves_like "a proposal email"

    it "renders the receiver email" do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it "sets the sender name" do
      expect(sender_names(mail)).to eq([approver.full_name])
    end
  end

  describe "#step_reply_received" do
    let(:mail) { StepMailer.step_user_removed(approver, proposal) }

    it_behaves_like "a proposal email"
  end

  describe "#proposal_notification" do
    let(:mail) { StepMailer.proposal_notification(step_with_client_data) }

    it "displays purchase-step-specific language" do
      expect(mail.body.encoded).to include(
        step_with_client_data.decorate.noun
      )
    end
  end

  private

  def step_with_client_data
    @step_with_client_data ||= client_data_proposal.individual_steps.first
  end

  def client_data_proposal
    @client_data_proposal ||= create(:ncr_work_order, :with_approvers).proposal
  end

  def proposal
    @proposal ||= create(:proposal, :with_serial_approvers)
  end

  def approval
    proposal.individual_steps.first
  end

  def approver
    approval.user
  end
end
