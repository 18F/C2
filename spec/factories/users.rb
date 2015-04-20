FactoryGirl.define do
  factory :user do
    sequence(:email_address) {|n| "liono#{n}@some-cartoon-show.com" }
    first_name "Liono"
    last_name "Thunder"

    trait :with_delegate do
      after(:create) do |user|
        delegate = FactoryGirl.create(:user)
        user.outgoing_delegates.create!(assignee: delegate)
      end
    end
  end
end
