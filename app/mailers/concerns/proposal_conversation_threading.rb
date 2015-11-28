module ProposalConversationThreading
  extend ActiveSupport::Concern
  include ConversationThreading

  def assign_threading_headers(proposal)
    msg_id = "<proposal-#{proposal.id}@#{DEFAULT_URL_HOST}>"
    self.thread_id = msg_id
  end

  def send_proposal_email(proposal:, to_email:, from_email: nil, template_name: nil)
    @proposal = proposal.decorate

    assign_threading_headers(proposal)
    subject = subject(proposal)

    reply_email = reply_to_email().gsub('@', "+#{proposal.public_id}@")

    mail(
      to: to_email,
      subject: subject,
      from: from_email || default_sender_email,
      reply_to: reply_email,
      template_name: template_name
    )
  end

  def subject(proposal)
    if proposal.client_data_type == "Ncr::WorkOrder"
      client_data = proposal.client_data
      %Q(Request #{proposal.public_id}, #{client_data.organization_code}, #{client_data.building_id} from #{proposal.requester.email_address})
    else
      "Request #{proposal.public_id}"
    end
  end
end
