# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_token do
    access_token "MyString"
    user_id 1
    cart_id 1
    expires_at "2014-07-02 12:42:22"
  end
end
