namespace :report do
  desc "Show non-cancelled old fiscal year proposals"
  task old_fiscal_year: :environment do
    ok_to_act = ENV['OK_TO_ACT'] ? true : false
    now = Time.zone.now
    this_fiscal_year_start = (now.month >= 10) ? now.year : now.year - 1
    puts "Pending proposals created before #{this_fiscal_year_start}-10-01"
    proposals = Proposal.pending.where("created_at < '#{this_fiscal_year_start}-10-01'")
    proposals.each do |proposal|
      if !proposal.requester
        puts "#{proposal.id} <= no Requester defined"
        if ok_to_act
          proposal.destroy
        end
      else
        puts "#{proposal.public_id} -> #{proposal.requester.email_address}"
        if ok_to_act
          send_reminder_email(proposal)
        end
      end
    end
  end

  private

  def send_reminder_email(proposal)
    # TODO
  end
end
