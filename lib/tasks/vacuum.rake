namespace :vacuum do
  desc "Clean up old fiscal year proposals"
  task old_proposals: :environment do
    ok_to_act = ENV['OK_TO_ACT'] ? true : false
    verbose = ENV['VERBOSE']
    vacuum = Vacuum.new(Time.zone.now, ok_to_act, verbose)
    verbose and puts "Pending proposals created before #{vacuum.fiscal_year_start}"
    vacuum.old_proposals
  end
end
