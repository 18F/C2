FactoryGirl.define do
  factory :approval_group do
    name "RobsApprovalGroup"

    factory :approval_group_with_approvers_and_requester do
      after :create do |approval_group|
        approver1 = User.find_by(email_address: 'approver1@some-dot-gov.gov') || FactoryGirl.create(:user, email_address: 'approver1@some-dot-gov.gov')
        approver2 = User.find_by(email_address: 'approver1@some-dot-gov.gov') || FactoryGirl.create(:user, email_address: 'approver2@some-dot-gov.gov')
        requester1 = User.find_by(email_address: 'requester1@some-dot-gov.gov') || FactoryGirl.create(:user, email_address: 'requester1@some-dot-gov.gov')
        UserRole.create!(user_id: approver1.id, approval_group_id: approval_group.id, role: 'approver')
        UserRole.create!(user_id: approver2.id, approval_group_id: approval_group.id, role: 'approver')
        UserRole.create!(user_id: approver2.id, approval_group_id: approval_group.id, role: 'requester')
      end
   end

   # TODO: Add factory of Approvals for approvers

  end
end
