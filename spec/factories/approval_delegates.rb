FactoryGirl.define do
  factory :approval_delegate do
    assignee { create(:user) }
    assigner { create(:user) }
  end
end
