FactoryGirl.define do
  factory :approval_group, :class => ApprovalGroup  do
    name "RobsApprovalGroup"

    factory :multipleapprovers do
      after :create do |x|
        x.approvers << Approver.create(email_address: "george.jetson@spacelysprockets.com")
        x.approvers << Approver.create(email_address: "judy.jetson@spacelysprockets.com")
        x.save
      end
    end
  end
end
