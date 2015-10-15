FactoryGirl.define do
  factory :user do
    client_slug ENV['CLIENT_SLUG_DEFAULT'] || 'ncr'
    sequence(:email_address) {|n| "user#{n}@example.com" }
    sequence(:first_name) {|n| "FirstName#{n}" }
    sequence(:last_name) {|n| "LastName#{n}" }

    trait :with_delegate do
      after(:create) do |user|
        delegate = FactoryGirl.create(:user, client_slug: user.client_slug)
        user.add_delegate(delegate)
      end
    end
  end
end
