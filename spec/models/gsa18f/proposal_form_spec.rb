describe Gsa18f::ProposalForm do
  describe '#create_cart' do
    def approver_emails(form)
      cart = form.create_cart
      cart.approvals.map {|a| a.user.email_address }
    end

    it "adds 18fapprover@gsa.gov as approver email" do
      form = FactoryGirl.build(:gsa18f_proposal_form, product_name_and_description: 'test')
      expect(form).to be_valid

      expect(approver_emails(form)).to eq(%w(
        18fapprover@gsa.gov
      ))
    end

  end
end
