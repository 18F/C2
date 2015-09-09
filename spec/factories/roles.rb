FactoryGirl.define do
  factory :role do
    name "i-am-a-role"
    
    trait :observer do
      name "observer"
    end

  end
end
