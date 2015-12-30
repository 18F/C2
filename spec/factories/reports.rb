FactoryGirl.define do
  factory :report do
    name "my report"
    query { { text: "something", test_client_request: { "client_data.amount" => "<123" } }.to_json }
    shared false
    association :user, factory: :user

    transient do
      client_slug { "test" }
    end

    after(:create) do |report, evaluator|
      if evaluator.client_slug
        report.user.client_slug = evaluator.client_slug
        report.user.save!
      end
    end
  end

end
