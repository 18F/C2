desc "Populate the database with a bunch of Carts"
task :populate => :environment do
  Populator.create_carts_with_approvals
end
