# describe "User Tracking" do
#   include EnvVarSpecHelper
#   include ReturnToHelper
#
#   # Does not work, for some reason.
#   describe "logging in" do
#     it "causes a Visit to be created" do
#       user = create(:user)
#       login_as(user)
#       last_visit = Visit.order("started_at ASC").last
#
#       expect(last_visit.user).to eq(user)
#     end
#   end
# end
