namespace :reminder do
  desc "Send actionable approver reminder email for pending requests"
  task actionable_approvers: :environment do
    props = Proposal.pending.where(client_data_type: "Ncr::WorkOrder")
    props.each do |proposal|
      send_reminder_email(proposal)
    end
  end

  private

  def send_reminder_email(proposal)
    user = proposal.client_data.current_approver or return
    approval = proposal.individual_approvals.find_by(user: user)
    if ENV['SEND_OK']
      Dispatcher.on_approval_approved(approval)
    else
      puts "Remind #{user.email_address} #{proposal.id} #{proposal.created_at} #{approval.id} #{approval.created_at}"
    end
  end
end
