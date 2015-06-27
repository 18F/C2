class Dispatcher
  def email_approver(approval)
    approval.create_api_token!
    send_notification_email(approval)
  end

  def email_observer(observation)
    proposal = observation.proposal
    CommunicartMailer.proposal_observer_email(observation.user_email_address, proposal).deliver_now
  end

  def email_observers(proposal)
    proposal.observations.each do |observation|
      self.email_observer(observation)
    end
  end

  def email_sent_confirmation(proposal)
    CommunicartMailer.proposal_created_confirmation(proposal).deliver_now
  end

  def deliver_new_proposal_emails(proposal)
    proposal.currently_awaiting_approvals.each do |approval|
      self.email_approver(approval)
    end
    self.email_observers(proposal)
    self.email_sent_confirmation(proposal)
  end

  def deliver_cancellation_emails(proposal)
    #CURRENT: send out cancellation emais
    # Loop through all people and send an email
    # CommunicartMailer.proposal_observer_email(observation.user_email_address, proposal).deliver_now
  end

  def requires_approval_notice?(approval)
    true
  end

  def on_proposal_rejected(proposal)
    rejection = proposal.approvals.rejected.first
    # @todo rewrite this email so a "rejection approval" isn't needed
    CommunicartMailer.approval_reply_received_email(rejection).deliver_now
    self.email_observers(proposal)
  end

  def on_approval_approved(approval)
    if self.requires_approval_notice?(approval)
      CommunicartMailer.approval_reply_received_email(approval).deliver_now
    end

    self.email_observers(approval.proposal)
  end

  def on_comment_created(comment)
    comment.listeners.each{|user|
      CommunicartMailer.comment_added_email(comment, user.email_address).deliver_now
    }
  end

  def on_proposal_update(proposal)
  end

  # todo: replace with dynamic dispatch
  def self.initialize_dispatcher(proposal)
    case proposal.flow
    when 'parallel'
      self.new
    when 'linear'
      # @todo: dynamic dispatch for selection
      if proposal.client == "ncr"
        NcrDispatcher.new
      else
        LinearDispatcher.new
      end
    end
  end

  # TODO DRY the following up

  def self.deliver_new_proposal_emails(proposal)
    dispatcher = self.initialize_dispatcher(proposal)
    dispatcher.deliver_new_proposal_emails(proposal)
  end

  def self.deliver_cancellation_emails(proposal)
    dispatcher = self.initialize_dispatcher(proposal)
    dispatcher.deliver_cancellation_emails(proposal)
  end

  def self.on_proposal_rejected(proposal)
    dispatcher = self.initialize_dispatcher(proposal)
    dispatcher.on_proposal_rejected(proposal)
  end

  def self.on_approval_approved(approval)
    dispatcher = self.initialize_dispatcher(approval.proposal)
    dispatcher.on_approval_approved(approval)
  end

  def self.on_comment_created(comment)
    dispatcher = self.initialize_dispatcher(comment.proposal)
    dispatcher.on_comment_created(comment)
  end

  def self.email_approver(approval)
    dispatcher = self.initialize_dispatcher(approval.proposal)
    dispatcher.email_approver(approval)
  end

  def self.on_proposal_update(proposal)
    dispatcher = self.initialize_dispatcher(proposal)
    dispatcher.on_proposal_update(proposal)
  end

  def self.on_observer_added(observation)
    dispatcher = self.initialize_dispatcher(observation.proposal)
    dispatcher.email_observer(observation)
  end

  private

  def send_notification_email(approval)
    email = approval.user_email_address
    CommunicartMailer.actions_for_approver(email, approval).deliver_now
  end
end
