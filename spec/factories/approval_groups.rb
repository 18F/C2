FactoryGirl.define do
  factory :approval_group do
    name "RobsApprovalGroup"

    factory :approval_group_with_approvers do
      after :create do |approval_group|
        user1 = User.find_by(email_address: 'approver1@some-dot-gov.gov') || FactoryGirl.create(:user, email_address: 'approver1@some-dot-gov.gov')
        user2 = User.find_by(email_address: 'approver1@some-dot-gov.gov') || FactoryGirl.create(:user, email_address: 'approver2@some-dot-gov.gov')
        UserRole.create!(user_id: user1.id, approval_group_id: approval_group.id, role: 'approver')
        UserRole.create!(user_id: user2.id, approval_group_id: approval_group.id, role: 'approver')
      end
   end

   # TODO: Add factory of Approvals for approvers

  end
end
