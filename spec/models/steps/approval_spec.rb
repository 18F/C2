require 'rails_helper'

describe Steps::Approval do
  describe "Validations" do
    it "disallows assigning approver as requester" do
      proposal = create(:proposal, :with_approver)
      expect {
        create(:approval_step, user: proposal.requester, proposal: proposal)
      }.to raise_error(/User Cannot be Requester/)
    end
  end
end
