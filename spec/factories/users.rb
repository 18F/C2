FactoryGirl.define do
  factory :user do
    sequence(:email_address) {|n| "user#{n}@example.com" }
    sequence(:first_name) {|n| "FirstName#{n}" }
    sequence(:last_name) {|n| "LastName#{n}" }

    trait :admin do
      after(:create) do |user|
        user.roles << Role.find_or_create_by(name: 'admin')
      end
    end

    trait :with_delegate do
      after(:create) do |user|
        delegate = create(:user)
        user.add_delegate(delegate)
      end
    end
  end
end
