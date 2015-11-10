namespace :vacuum do
  desc "Clean up old fiscal year proposals"
  task old_proposals: :environment do
    ok_to_act = ENV["OK_TO_ACT"] ? true : false
    verbose = ENV["VERBOSE"]
    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act, verbose)
    verbose and puts "Pending proposals created before #{vacuum.fiscal_year_start}"
    cleaner.vacuum_old_proposals
  end
end
