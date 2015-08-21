module ProposalConversationThreading
  ## helper methods ##

  def self.msg_id(proposal)
    "<proposal-#{proposal.id}@#{DEFAULT_URL_HOST}>"
  end

  def self.subject_i18n_key(proposal)
    if proposal.client_data
      # We'll look up by the client_data's class name
      proposal.client_data.class.name.underscore
    else
      # Default (no client_data): look up by "proposal"
      :proposal
    end
  end

  def self.subject_params(proposal)
    params = proposal.as_json
    # todo: replace with public_id once #98376564 is fixed
    params[:public_identifier] = proposal.public_identifier
    # Add in requester params
    proposal.requester.as_json.each { |k, v| params["requester_" + k] = v }
    if proposal.client_data
      # Add in client_data params
      params.merge!(proposal.client_data.as_json)
    end
    # Add search path, and default lookup key for I18n
    params.merge!(scope: [:mail, :subject], default: :proposal)

    params
  end

  def self.subject(proposal)
    i18n_key = self.subject_i18n_key(proposal)
    params = self.subject_params(proposal)
    I18n.t(i18n_key, params.symbolize_keys)
  end

  ###################

  ## mixin methods ##

  protected

  def assign_threading_headers(proposal)
    msg_id = ProposalConversationThreading.msg_id(proposal)

    # http://www.jwz.org/doc/threading.html
    headers['In-Reply-To'] = msg_id
    headers['References'] = msg_id
  end

  def send_proposal_email(proposal:, to_email:, from_email: nil, template_name: nil)
    @proposal = proposal.decorate

    self.assign_threading_headers(proposal)
    subject = ProposalConversationThreading.subject(proposal)

    mail(
      to: to_email,
      subject: subject,
      from: from_email || default_sender_email,
      template_name: template_name
    )
  end

  ###################
end
