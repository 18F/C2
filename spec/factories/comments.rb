FactoryGirl.define do
  factory :comment do
    comment_text "MyText"
    user
    proposal
  end
end
