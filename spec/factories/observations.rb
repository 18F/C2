FactoryGirl.define do
  factory :observation do
    user_id { create(:user).id }
    proposal_id { create(:proposal).id }
    role_id { Role.where(name: ROLE_OBSERVER).pluck(:id) }
  end
end
