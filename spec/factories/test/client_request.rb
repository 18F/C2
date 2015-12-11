FactoryGirl.define do
  factory :test_client_request, class: Test::ClientRequest do
    amount 123
    project_title "I am a test request"
    association :proposal, flow: "linear"

    trait :with_approvers do
      association :proposal, :with_serial_approvers, flow: 'linear', client_slug: "test"
    end
  end
end
