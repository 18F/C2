describe Ncr::ProposalForm do
  describe '#create_cart' do
    def approver_emails(form)
      cart = form.create_cart
      approvals = cart.ordered_approvals
      approvals.map {|a| a.user.email_address }
    end

    it "adds the budget approver for a BA80 request" do
      form = FactoryGirl.build(:proposal_form, expense_type: 'BA80',
                               approver_email: 'aaa@example.com')
      expect(form).to be_valid

      expect(approver_emails(form)).to eq(%w(
        aaa@example.com
        communicart.budget.approver@gmail.com
      ))
    end

    it "adds the two approvers for a BA61 request" do
      form = FactoryGirl.build(:proposal_form, expense_type: 'BA61',
                               approver_email: 'bbb@example.com')
      expect(form).to be_valid

      expect(approver_emails(form)).to eq(%w(
        bbb@example.com
        communicart.budget.approver@gmail.com
        communicart.ofm.approver@gmail.com
      ))
    end
  end

  describe 'from_cart' do
    it 'sets the correct fields' do
      cart = FactoryGirl.create(:cart_with_approvals)
      form = Ncr::ProposalForm.from_cart(cart)
      expect(form.approver_email).to eq('approver1@some-dot-gov.gov')
      expect(form.description).to eq('Test Cart needing approval')
      expect(form.amount).to be_nil
    end

    it 'also sets properties and ignores extra props' do
      cart = FactoryGirl.create(:cart_with_approvals)
      cart.set_props(some_field: "a value", amount: 1234.56)
      form = Ncr::ProposalForm.from_cart(cart)
      expect(form.amount).to eq(1234.56)
    end
  end
end
