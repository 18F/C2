describe Gsa18f::ProposalForm do
  describe '#create_cart' do
    def approver_emails(form)
      cart = form.create_cart
      approvals = cart.ordered_approvals
      approvals.map {|a| a.user.email_address }
    end

    it "adds Ric Miller as approver email" do
      form = FactoryGirl.build(:gsa18f_proposal_form, product_name_and_description: 'test')
      expect(form).to be_valid

      expect(approver_emails(form)).to eq(%w(
        Richard.L.Miller@gsa.gov
      ))
    end

  end
end
