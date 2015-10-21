module IncomingMail
  class Handler
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
      payload.is_a?(Array) and payload[0]['event'] and payload[0]['event'] == 'inbound'
    end

    def create_response(payload)
      resp = Response.new(type: identify_mail_type(payload))
      case resp.type
      when REQUEST
        resp.comment = create_comment(payload['msg'])
        resp.action = resp.comment ? Response::COMMENT : Response::ERROR
      else
        forward_msg(payload['msg']['raw_msg'])
        resp.action = Response::FORWARDED
      end
      resp
    end

    def identify_mail_type(payload)
      subject = payload['msg']['subject']
      references = payload['msg']['headers']['References']
      if subject_line_matches(subject)
        return IncomingMail::REQUEST
      elsif references and reference_header_matches(references)
        return IncomingMail::REQUEST
      else
        return IncomingMail::UNKNOWN
      end
    end

    def subject_line_matches(subject)
      subject.match(/Request (#|FY)\d+/)
    end

    def reference_header_matches(header)
      header.match(/<proposal-\d+/)
    end

    def forward_msg(msg)
      CommunicartMailer.resend(msg).deliver_later
    end

    def create_comment(msg)
      # IMPORTANT that we check/add as observer before we create comment,
      # since comment will create as a user if not already,
      # and we want the reason logged.
      parsed_email = InboundMailParser.new(msg)
      proposal = parsed_email.proposal
      user = parsed_email.comment_user


      unless proposal.existing_observation_for(user)
        reason = "Added comment via email reply"
        ObservationCreator.new(
          observer: user,
          proposal_id: proposal.id,
          reason: reason,
        ).run
      end

      comment = Comment.create(
        comment_text: parsed_email.comment_text,
        user: parsed_email.comment_user,
        proposal: parsed_email.proposal
      )

      Dispatcher.on_comment_created(comment) # sends email
      comment
    end
  end
end
