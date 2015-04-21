FactoryGirl.define do
  factory :attachment do
    file_file_name 'example.png'
    file_content_type 'image/png'
    file_file_size 1000
    user
    proposal
  end
end
