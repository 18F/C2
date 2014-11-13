FactoryGirl.define do
  factory :user do
    sequence(:email_address) {|n| "liono#{n}@some-cartoon-show.com" }
    first_name "Liono"
    last_name "Thunder"
  end
end
