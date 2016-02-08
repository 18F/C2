require "elasticsearch/rails/ha/tasks"

namespace :search do
  desc "re-index all records, in parallel"
  task index: :environment do
    delegate_to_ha_method("index")
  end

  desc "stage an index build"
  task stage: :environment do
    delegate_to_ha_method("stage")
  end

  desc "promote a staged index"
  task promote: :environment do
    delegate_to_ha_method("promote")
  end

  def delegate_to_ha_method(method_name)
    ENV["CLASS"] = "Proposal"
    Rake::Task["elasticsearch:ha:#{method_name}"].invoke
    Rake::Task["elasticsearch:ha:#{method_name}"].reenable
  end
end
