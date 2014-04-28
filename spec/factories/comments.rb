# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    comment_text "MyText"
    cart_id 1
  end
end
