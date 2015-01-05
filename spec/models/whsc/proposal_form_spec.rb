describe Whsc::ProposalForm do
  describe '#create_cart' do
    def approver_emails(form)
      cart = form.create_cart
      approvals = cart.ordered_approvals
      approvals.map {|a| a.user.email_address }
    end

    it "adds the budget approver for a BA80 request" do
      form = FactoryGirl.build(:proposal_form, expense_type: 'BA80')
      expect(form).to be_valid

      expect(approver_emails(form)).to eq(%w(
        approver1@example.com
        communicart.budget.approver@gmail.com
      ))
    end

    it "adds the two approvers for a BA61 request" do
      form = FactoryGirl.build(:proposal_form, expense_type: 'BA61')
      expect(form).to be_valid

      expect(approver_emails(form)).to eq(%w(
        approver2@example.com
        communicart.budget.approver@gmail.com
        communicart.ofm.approver@gmail.com
      ))
    end
  end
end
