# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email_address "MyString"
    first_name "MyString"
    last_name "MyString"
  end
end
