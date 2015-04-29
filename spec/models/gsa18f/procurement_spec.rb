describe Gsa18f::Procurement do
  describe '#create_cart' do
    def approver_emails(procurement)
      procurement.proposal.approvals.map {|a| a.user.email_address }
    end

    it "adds 18fapprover@gsa.gov as approver email" do
      procurement = FactoryGirl.build(:gsa18f_procurement, :with_proposal, :with_approvers)
      expect(procurement).to be_valid

      expect(approver_emails(procurement)).to eq(%w(
        approver1@some-dot-gov.gov
        approver2@some-dot-gov.gov
      ))
    end
  end
end
