module ProposalConversationThreading
  protected

  def send_proposal_email(proposal:, to_email:, from_email: nil, template_name: nil)
    @proposal = proposal.decorate

    # http://www.jwz.org/doc/threading.html
    headers['In-Reply-To'] = @proposal.email_msg_id
    headers['References'] = @proposal.email_msg_id

    mail(
      to: to_email,
      subject: proposal_subject(@proposal),
      from: from_email || default_sender_email,
      template_name: template_name
    )
  end

  def proposal_subject_i18n_key(proposal)
    if proposal.client_data
      # We'll look up by the client_data's class name
      proposal.client_data.class.name.underscore
    else
      # Default (no client_data): look up by "proposal"
      :proposal
    end
  end

  def proposal_subject_params(proposal)
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

  def proposal_subject(proposal)
    i18n_key = proposal_subject_i18n_key(proposal)
    params = proposal_subject_params(proposal)
    I18n.t(i18n_key, params.symbolize_keys)
  end
end
