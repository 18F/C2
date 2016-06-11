FactoryGirl.define do
  factory :observation do
    user_id { create(:user).id }
    proposal_id { create(:proposal).id }
    role_id { Role.find_by!(name: ROLE_OBSERVER).id }
  end
end
