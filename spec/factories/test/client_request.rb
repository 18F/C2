# because Test::ClientRequest is not in app/model,
# Rails load order means that we must check first for the namespace
# being defined before we can create the factory.
# This file is explicitly "required"-ed from within the fixture file.
FactoryGirl.define do
  begin
    if Module.const_get("Test::ClientRequest")
      factory :test_client_request, class: Test::ClientRequest do
        amount 123
        project_title "I am a test request"
        association :proposal, client_slug: "test"
        association :approving_official, factory: :user, client_slug: "test"

        trait :with_approvers do
          association :proposal, :with_serial_approvers, client_slug: "test"
        end
      end
    end
  rescue NameError
  # do nothing
  end
end
