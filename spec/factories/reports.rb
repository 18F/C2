FactoryGirl.define do
  factory :report do
    name "my report"
    query do
      {
        text: "something",
        humanized: "(something) AND (Amount:<123)",
        test_client_request: { "client_data.amount" => "<123" }
      }.to_json
    end
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
