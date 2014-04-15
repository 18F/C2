# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cart_item do
    vendor "MyString"
    description "MyText"
    url "MyString"
    notes "MyText"
    quantity 1
    details "MyText"
    part_number "MyString"
    price 1.5
    cart_id 123456
    external_id 1357911
  end
end
