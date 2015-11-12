namespace :vacuum do
  desc "Clean up old fiscal year proposals"
  task old_proposals: :environment do
    ok_to_act = ENV["OK_TO_ACT"] ? true : false
    verbose = ENV["VERBOSE"]
    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act, verbose)
    verbose and puts "Pending proposals created before #{vacuum.fiscal_year_start}"
    cleaner.vacuum_old_proposals
  end

  desc "Clean up old proposal"
  task old_proposal: :environment do
    ok_to_act = ENV["OK_TO_ACT"] ? true : false
    verbose = ENV["VERBOSE"]
    proposal_id = ENV["PROPOSAL_ID"] or raise "PROPOSAL_ID required"
    proposal = Proposal.find(proposal_id)
    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act, verbose)
    cleaner.vacuum_proposal(proposal)
  end
end
