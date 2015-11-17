namespace :vacuum do
  desc "Clean up old fiscal year proposals"
  task old_proposals: :environment do
    ok_to_act = false
    if ENV["OK_TO_ACT"] && ENV["OK_TO_ACT"].match(/^[yt]/i)
      ok_to_act = true
    end
    verbose = false
    if ENV["VERBOSE"] && ENV["VERBOSE"].match(/^[yt]/i)
      verbose = true
    end
    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act: ok_to_act, verbose: verbose)
    if verbose
      STDERR.puts "Pending proposals created before #{vacuum.fiscal_year_start}"
    end
    cleaner.vacuum_old_proposals
  end

  desc "Clean up old proposal"
  task old_proposal: :environment do
    ok_to_act = false
    if ENV["OK_TO_ACT"] && ENV["OK_TO_ACT"].match(/^[yt]/i)
      ok_to_act = true
    end
    verbose = false
    if ENV["VERBOSE"] && ENV["VERBOSE"].match(/^[yt]/i)
      verbose = true
    end
    proposal_id = ENV["PROPOSAL_ID"] or raise "PROPOSAL_ID required"
    proposal = Proposal.find(proposal_id)
    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act: ok_to_act, verbose: verbose)
    cleaner.vacuum_proposal(proposal)
  end
end
