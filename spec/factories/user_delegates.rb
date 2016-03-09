FactoryGirl.define do
  factory :user_delegate do
    assignee { create(:user) }
    assigner { create(:user) }
  end
end
