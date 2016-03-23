class ExpiredRecordCleaner
  attr_reader :verbose, :fiscal_year_start

  def initialize(datetime, args = {})
    @fiscal_year_start = calc_fiscal_year_start(datetime)
    @ok_to_act = args[:ok_to_act]
    @verbose = args[:verbose]
  end

  def vacuum_old_proposals
    proposals = Proposal.pending.where("created_at < ?", @fiscal_year_start)
    ids = []
    proposals.each do |proposal|
      vacuum_proposal(proposal)
      ids << proposal.id
    end
    ids
  end

  def vacuum_proposal(proposal)
    if !proposal.requester
      handle_no_requester(proposal)
    else
      handle_cancelation(proposal)
    end
  end

  private

  def calc_fiscal_year_start(dtim)
    year = (dtim.month >= 10) ? dtim.year : dtim.year - 1
    Time.zone.parse("#{year}-10-01")
  end

  def notify_proposal_requester(proposal)
    CancelationMailer.fiscal_cancelation_notification(proposal).deliver_later
  end

  def handle_no_requester(proposal)
    if @verbose && !Rails.env.test?
      STDERR.puts "#{proposal.id} <= no Requester defined"
    end
    if @ok_to_act
      proposal.destroy
    else
      notify_no_action_taken_if_non_test_env(proposal)
    end
  end

  def handle_cancelation(proposal)
    if @verbose && !Rails.env.test?
      STDERR.puts "#{proposal.public_id} -> #{proposal.requester.email_address}"
    end

    if @ok_to_act
      notify_proposal_requester(proposal)
      proposal.cancel!
    else
      notify_no_action_taken_if_non_test_env(proposal)
    end
  end

  def notify_no_action_taken_if_non_test_env(proposal)
    unless Rails.env.test?
      STDERR.puts "set OK_TO_ACT=true to clean up #{proposal.id}"
    end
  end
end
