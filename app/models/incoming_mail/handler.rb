module IncomingMail
  class Handler
    include MailAddressing

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def handle(payload)
      if payload_is_raw?(payload)
        create_response(payload[0])
      elsif payload.is_a?(Mandrill::WebHook::EventDecorator)
        create_response(payload)
      else
        fail "Invalid Mandrill event payload. Must be event==inbound or Mandrill::WebHook::EventDecorator instance"
      end
    end

    private

    def payload_is_raw?(payload)
      payload.is_a?(Array) and payload[0]["event"] and payload[0]["event"] == "inbound"
    end

    def create_response(payload)
      response = Response.new(type: identify_mail_type(payload))

      if response.type == REQUEST && response.comment = transform_msg_to_comment(payload["msg"])
        response.action = Response::COMMENT
        send_comment_email(response.comment)
      else
        forward_message(response, payload)
      end

      response
    end

    def loop?(msg)
      mail_msg = Mail.new(msg["raw_msg"])
      from_raw = msg["headers"]["From"] || mail_msg.header["From"].value
      from_raw == resend_to_email || resend_to_email.match("<#{from_raw}>")
    end

    def forward_message(response, payload)
      if loop?(payload["msg"])
        response.action = Response::DROPPED
      else
        Mailer.resend(payload["msg"]["raw_msg"]).deliver_later
        response.action = Response::FORWARDED
      end
    end

    def identify_mail_type(payload)
      subject = payload["msg"]["subject"]
      references = payload["msg"]["headers"]["References"]
      if subject_line_matches(subject)
        IncomingMail::REQUEST
      elsif references && reference_header_matches(references)
        IncomingMail::REQUEST
      else
        IncomingMail::UNKNOWN
      end
    end

    def subject_line_matches(subject)
      subject.match(/Request (#|FY)\d+/)
    end

    def reference_header_matches(header)
      header.match(/<proposal-\d+/)
    end

    def transform_msg_to_comment(msg)
      parsed_email = InboundMailParser.new(msg)
      proposal = parsed_email.proposal
      user = parsed_email.comment_user

      # cannot create comment for non-existent user, or
      # for user who is not already a subscriber
      unless user && proposal.has_subscriber?(user)
        return
      end

      create_comment(parsed_email.comment_text, proposal, user)
    end

    def create_comment(comment_text, proposal, user)
      find_or_create_observation(proposal, user)

      Comment.create(
        comment_text: comment_text,
        user: user,
        proposal: proposal
      )
    end

    def find_or_create_observation(proposal, user)
      unless proposal.existing_observation_for(user)
        reason = "Added comment via email reply"
        ObservationCreator.new(
          observer: user,
          proposal_id: proposal.id,
          reason: reason,
        ).run
      end
    end

    def send_comment_email(comment)
      DispatchFinder.run(comment.proposal).on_comment_created(comment)
    end
  end
end
