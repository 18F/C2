FactoryGirl.define do
  factory :approval_group do
    name "RobsApprovalGroup"

    factory :approval_group_with_approvers do
      after :create do |approval_group|
        approval_group.requester = FactoryGirl.create(:requester)

        # TODO: Remove approvers
        approval_group.approvers << Approver.create(email_address: "george.jetson@spacelysprockets.com")
        approval_group.approvers << Approver.create(email_address: "judy.jetson@spacelysprockets.com")

        approval_group.users << FactoryGirl.create(:user, email_address: 'approver1@some-dot-gov.gov')
        approval_group.users << FactoryGirl.create(:user, email_address: 'approver2@some-dot-gov.gov')
        approval_group.save
      end
   end

  end
end
