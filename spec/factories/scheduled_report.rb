FactoryGirl.define do
  factory :scheduled_report do
    name "my scheduled report"
    frequency "none"
    association :user, factory: :user
    association :report, factory: :report

    transient do
      client_slug { "test" }
    end

    after(:create) do |scheduled_report, evaluator|
      if evaluator.client_slug
        scheduled_report.user.client_slug = evaluator.client_slug
        scheduled_report.user.save!
      end
    end
  end
end
