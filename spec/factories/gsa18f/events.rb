## To do: need to fix how client data is selected. 


# FactoryGirl.define do
#   factory :gsa18f_event, class: Gsa18f::Event do
#     duty_station "dc"
#     supervisor_id 1
#     title_of_event "eventTitle"
#     event_provider "EventProvider"
#     purpose "eventPurpose"
#     justification "event justification"
#     link "gsa.gov"
#     instructions "Event Instructions"
#     nfs_form "event NFS form"
#     cost_per_unit 100
#     estimated_travel_expenses 100
#     type_of_event 0
#     free_event false
#     travel_required false
#     association :proposal, client_slug: "gsa18f"


#     trait :with_steps do
#       after(:create) { |event| event.initialize_steps }
#     end

#     trait :with_beta_requester do
#       after(:create) do |event|
#         event.initialize_steps
#         requester = event.requester
#         requester.roles << Role.find_by!(name: ROLE_BETA_USER)
#         requester.roles << Role.find_by!(name: ROLE_BETA_ACTIVE)
#       end
#     end

#     trait :with_beta_steps do
#       after(:create) do |event|
#         event.initialize_steps
#         proposal = event.proposal
#         ind = 3.times.map { Steps::Approval.new(user: create(:user, client_slug: "gsa18f")) }
#         proposal.add_initial_steps(ind)
#         requester = event.requester
#         requester.roles << Role.find_by!(name: ROLE_BETA_USER)
#         requester.roles << Role.find_by!(name: ROLE_BETA_ACTIVE)
#       end
#     end

#   end
# end
