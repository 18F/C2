class Vacuum
  attr_reader :verbose, :fiscal_year_start

  def initialize(dtim, ok_to_act=false, verbose=false)
    @fiscal_year_start = fiscal_year_start(dtim)
    @ok_to_act = ok_to_act
    @verbose = verbose
  end

  def fiscal_year_start(dtim)
    year = (dtim.month >= 10) ? dtim.year : dtim.year - 1
    DateTime.parse("#{year.to_s}-10-01")
  end

  def old_proposals
    proposals = Proposal.pending.where("created_at < '#{@fiscal_year_start}'")
    proposals.each do |proposal|
      if !proposal.requester
        @verbose && puts "#{proposal.id} <= no Requester defined"
        if @ok_to_act
          proposal.destroy
        end 
      else
        @verbose && puts "#{proposal.public_id} -> #{proposal.requester.email_address}"
        if @ok_to_act
          send_reminder_email(proposal)
        end 
      end 
    end
  end

  def send_reminder_email(proposal)

  end
end
