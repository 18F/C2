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
      proposal = find_proposal(find_public_id(msg)) or return
      comment_text = find_comment_text(msg)
      comment_user = find_comment_user(msg)
      if proposal.has_subscriber?(comment_user)
        # already in the loop, just add comment.
        proposal.comments.create(comment_text: comment_text, user: comment_user)
      else
        # yes, user adds self as observer, which also generates comment
        proposal.add_observer(comment_user, comment_user, comment_text)
        proposal.comments.last
      end
    end

    def find_proposal(public_id)
      Proposal.find_by_public_id(public_id) || Proposal.find(public_id)
    end

    def find_public_id(msg)
      references = msg['headers']['References']
      ref_re = /<proposal-(\d+)\@.+?>/
      sbj_re = /Request\ #?([\w\-]+)/

      if references.match(ref_re)
        references.match(ref_re)[1]
      elsif msg['subject'].match(sbj_re)
        msg['subject'].match(sbj_re)[1]
      else
        fail "Failed to find public_id in msg #{msg.inspect}"
      end
    end

    def find_comment_text(msg)
      EmailReplyParser.parse_reply(msg['text'])
    end

    def find_comment_user(msg)
      from = msg['from_email']
      User.find_by_email_address(from)
    end
  end
end
