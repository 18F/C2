FactoryGirl.define do
  factory :cart_item do
    vendor "Test Vendor"
    description "This is a test cart item"
    url "http://some.product.url/12345"
    notes "This is a note for a test cart item"
    quantity 100
    details "Details for a test cart item"
    part_number "1A2B3C4D"
    price 1.5
    cart_id 1357911
  end
  factory :cart_item_with_trait do
    vendor "Test Vendor2"
    description "This is another test cart item"
    url "http://some.product.url/12345"
    notes "This is a note for a test cart item"
    quantity 100
    details "Details for a test cart item"
    part_number "1A2B3C4D"
    price 1.5
    cart_id 1357911
  end
end
