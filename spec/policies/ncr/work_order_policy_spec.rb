describe Ncr::WorkOrderPolicy do
  subject { described_class }

  permissions :can_edit? do
    let(:work_order) { FactoryGirl.create(:ncr_work_order, :with_approvers) }
    let(:proposal) { work_order.proposal }

    it "allows the requester to edit it" do
      expect(subject).to permit(work_order.requester, work_order)
    end

    it "allows an approver to edit it" do
      expect(subject).to permit(work_order.approvers[0], work_order)
      expect(subject).to permit(work_order.approvers[1], work_order)
    end

    it "doesn't allow an observer to edit it" do
      observer = FactoryGirl.create(:user)
      proposal.observations.create!(user: observer)
      expect(subject).not_to permit(observer, work_order)
    end

    it "does not allow anyone else to edit it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), work_order)
    end

    it "allows an approved request to be edited" do
      proposal.update_attribute(:status, 'approved')  # skip state machine
      expect(subject).to permit(proposal.requester, work_order)
    end
  end

  permissions :can_create? do
    it "allows a user with an arbitrary email to create" do
      user = User.new(email_address: 'user@some.com')
      work_order = Ncr::WorkOrder.new
      expect(subject).to permit(user, work_order)
    end

    with_feature 'RESTRICT_ACCESS' do
      it "allows someone with a GSA email to create" do
        user = User.new(email_address: 'user@gsa.gov')
        work_order = Ncr::WorkOrder.new
        expect(subject).to permit(user, work_order)
      end

      it "doesn't allow someone with a non-GSA email to create" do
        user = User.new(email_address: 'intruder@some.com')
        work_order = Ncr::WorkOrder.new
        expect(subject).not_to permit(user, work_order)
      end
    end
  end
end
