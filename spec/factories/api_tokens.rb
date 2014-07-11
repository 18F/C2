FactoryGirl.define do
  factory :api_token do
    access_token "10a9b8c7d6e"
    user_id 1
    cart_id 1
    expires_at "2014-07-02 12:42:22"
  end
end
