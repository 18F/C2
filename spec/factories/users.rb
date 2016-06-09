FactoryGirl.define do
  factory :user do
    client_slug { nil }
    sequence(:email_address) {|n| "user#{n}@example.com" }
    sequence(:first_name) {|n| "FirstName#{n}" }
    sequence(:last_name) {|n| "LastName#{n}" }
    timezone { Time.zone.name }

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    trait :admin do
      after(:create) do |user|
        user.roles << Role.find_or_create_by(name: 'admin')
      end
    end

    trait :beta_user do
      after(:create) do |user|
        user.roles << Role.find_or_create_by(name: 'beta_user')
      end
    end

    trait :beta_active do
      after(:create) do |user|
        user.roles << Role.find_or_create_by(name: 'beta_user')
        user.roles << Role.find_or_create_by(name: 'beta_active')
      end
    end

    trait :client_admin do
      after(:create) do |user|
        user.roles << Role.find_or_create_by(name: 'client_admin')
      end
    end

    trait :gateway_admin do
      after(:create) do |user|
        user.roles << Role.find_or_create_by(name: 'gateway_admin')
      end
    end

    trait :with_delegate do
      after(:create) do |user|
        delegate = create(:user, client_slug: user.client_slug)
        user.add_delegate(delegate)
      end
    end
  end
end
