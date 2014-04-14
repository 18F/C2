FactoryGirl.define do
  factory :approval_group, :class => ApprovalGroup  do
    name "RobsApprovalGroup"

    factory :multipleapprovers do #TODO: Rename
      after :create do |approval_group|
        approval_group.approvers << Approver.create(email_address: "george.jetson@spacelysprockets.com")
        approval_group.approvers << Approver.create(email_address: "judy.jetson@spacelysprockets.com")
        approval_group.save
      end
    end
  end
end
