FactoryGirl.define do
  factory :approval_group do
    name "RobsApprovalGroup"

    factory :approval_group_with_approvers do
      after :create do |approval_group|
        approval_group.requester = FactoryGirl.create(:requester)

        approval_group.approvers << Approver.create(email_address: "george.jetson@spacelysprockets.com")
        approval_group.approvers << Approver.create(email_address: "judy.jetson@spacelysprockets.com")
        approval_group.save
      end
    end
  end
end
