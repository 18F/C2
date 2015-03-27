namespace :populate do
  desc "Populate the database with identical Carts"
  task uniform: :environment do
    Populator.create_carts_with_approvals
  end

  desc "Populate the database with random NCR data"
  task random_ncr: :environment do
    Populator.random_ncr_data
  end
end
