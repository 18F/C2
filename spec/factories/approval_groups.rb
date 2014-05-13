FactoryGirl.define do
  factory :approval_group do
    name "RobsApprovalGroup"

    factory :approval_group_with_approvers do
      after :create do |approval_group|
        approval_group.requester = FactoryGirl.create(:requester)

        approval_group.users << FactoryGirl.create(:user, email_address: 'approver1@some-dot-gov.gov')
        approval_group.users << FactoryGirl.create(:user, email_address: 'approver2@some-dot-gov.gov')
        approval_group.save
      end
   end

   # TODO: Add factory of Approvals for approvers above

  end
end
