FactoryGirl.define do
  factory :observation do
    user_id { create(:user).id }
    proposal_id { create(:proposal).id }
    role_id { Role.find_or_create_by(name: "observer").id }
  end
end
