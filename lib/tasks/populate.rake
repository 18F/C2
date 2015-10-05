namespace :populate do
  namespace :ncr do
    desc "Populate the database with identical NCR data"
    task uniform: :environment do
      Populator.new.uniform_ncr_data
    end

    desc "Populate the database with random NCR data"
    task random: :environment do
      Populator.new.random_ncr_data
    end

    desc "Populate database for a user based on email passed in"
    task :for_user, [:email] => [:environment] do |t, args|
      Populator.new.ncr_data_for_user(email: args[:email])
    end
  end
end
