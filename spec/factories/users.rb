FactoryGirl.define do
  factory :user do
    # don't freak out if the database isn't created yet
    # http://stackoverflow.com/a/27745684/358804
    num_users = if ActiveRecord::Base.connection.table_exists?(User.table_name)
      User.count
    else
      0
    end

    sequence(:email_address, num_users) {|n| "liono#{n}@some-cartoon-show.com" }
    first_name "Liono"
    last_name "Thunder"

    trait :with_delegate do
      after(:create) do |user|
        delegate = FactoryGirl.create(:user)
        user.add_delegate(delegate)
      end
    end
  end
end
