namespace :populate do
  namespace :ncr do
    desc "Populate the database with identical NCR data"
    task uniform: :environment do
      Populator.uniform_ncr_data
    end

    desc "Populate the database with random NCR data"
    task random: :environment do
      Populator.random_ncr_data
    end
  end
end
