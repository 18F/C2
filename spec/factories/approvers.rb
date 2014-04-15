FactoryGirl.define do
  factory :approver do
    email_address 'approver@some-dot-gov.gov'
    status 'pending'
    approval_group_id '123'
  end
end