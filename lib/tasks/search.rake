require "elasticsearch/rails/ha/tasks"

namespace :search do
  desc "re-index all records, in parallel"
  task index: :environment do
    ENV["CLASS"] = "Proposal"
    Rake::Task["elasticsearch:ha:import"].invoke
    Rake::Task["elasticsearch:ha:import"].reenable
  end

  desc "stage an index build"
  task stage: :environment do
    ENV["CLASS"] = "Proposal"
    Rake::Task["elasticsearch:ha:stage"].invoke
    Rake::Task["elasticsearch:ha:stage"].reenable
  end

  desc "promote a staged index"
  task promote: :environment do
    ENV["CLASS"] = "Proposal"
    Rake::Task["elasticsearch:ha:promote"].invoke
    Rake::Task["elasticsearch:ha:promote"].reenable
  end
end
