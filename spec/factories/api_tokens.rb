FactoryGirl.define do
  sequence(:access_token) { |n| "123ABC#{n}" }

  factory :api_token do
    access_token
    step
    expires_at { Time.current + 7.days }
  end
end
