class Vacuum
  attr_reader :verbose, :fiscal_year_start

  def initialize(dtim, ok_to_act = false, verbose = false)
    @fiscal_year_start = self.class.fiscal_year_start(dtim)
    @ok_to_act = ok_to_act
    @verbose = verbose
  end

  def old_proposals
    proposals = Proposal.pending.where("created_at < '#{@fiscal_year_start}'")
    ids = []
    proposals.each do |proposal|
      proposal(proposal)
      ids << proposal.id
    end
    ids
  end

  def proposal(proposal)
    if !proposal.requester
      handle_no_requester(proposal)
    else
      handle_cancellation(proposal)
    end
  end

  private

  def self.fiscal_year_start(dtim)
    year = (dtim.month >= 10) ? dtim.year : dtim.year - 1
    Time.zone.parse("#{year}-10-01")
  end

  def send_reminder_email(proposal)
    CommunicartMailer.proposal_reminder(proposal).deliver_later
  end

  def handle_no_requester(proposal)
    @verbose and STDERR.puts "#{proposal.id} <= no Requester defined"
    if @ok_to_act
      proposal.destroy
    end
  end

  def handle_cancellation(proposal)
    @verbose and STDERR.puts "#{proposal.public_id} -> #{proposal.requester.email_address}"
    if @ok_to_act
      send_reminder_email(proposal)
      proposal.cancel!
    end
  end
end
