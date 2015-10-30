namespace :vacuum do
  desc "Show non-cancelled old fiscal year proposals"
  task old_proposals: :environment do
    ok_to_act = ENV['OK_TO_ACT'] ? true : false
    verbose = ENV['VERBOSE']
    now = Time.zone.now
    vacuum = Vacuum.new(now, ok_to_act, verbose)
    verbose && puts "Pending proposals created before #{vacuum.fiscal_year_start}"
    vacuum.old_proposals
  end
end
