namespace :vacuum do
  desc "Clean up old fiscal year proposals"
  task old_proposals: :environment do
    ok_to_act = false
    if ENV["OK_TO_ACT"] && ENV["OK_TO_ACT"].match(/^[yt]/i)
      ok_to_act = true
    end

    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act: ok_to_act)
    Rails.logger.info { "Pending proposals created before #{cleaner.fiscal_year_start}" }
    cleaner.vacuum_old_proposals
  end

  desc "Clean up old proposal"
  task old_proposal: :environment do
    ok_to_act = false
    if ENV["OK_TO_ACT"] && ENV["OK_TO_ACT"].match(/^[yt]/i)
      ok_to_act = true
    end

    proposal_id = ENV["PROPOSAL_ID"] or raise "PROPOSAL_ID required"
    proposal = Proposal.find(proposal_id)
    cleaner = ExpiredRecordCleaner.new(Time.zone.now, ok_to_act: ok_to_act)
    cleaner.vacuum_proposal(proposal)
  end
end
