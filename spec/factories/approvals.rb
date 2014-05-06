# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :approval do
    cart_id 1
    user_id 1
    status "MyString"
  end
end
