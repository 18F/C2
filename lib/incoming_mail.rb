module IncomingMail
  # mail_types
  UNKNOWN = 0
  REQUEST = 1

  class Handler
    # parses a Mandrill callback object and Does The Right Thing

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def handle(payload)
      resp = Response.new(type: identify_mail_type(payload))
      case resp.type
      when REQUEST
        resp.comment = create_comment(payload[0]['msg'])
        resp.action = resp.comment ? Response::COMMENT : Response::ERROR
      when UNKNOWN
        resp.action = Response::DROPPED
        # nothing else to do
      else
        # failed to identify the type
      end
      resp
    end

    def identify_mail_type(payload)
      subject = payload[0]['msg']['subject']
      if subject.match(/Request (#|FY)\d+/)
        return IncomingMail::REQUEST
      else
        return IncomingMail::UNKNOWN
      end
    end

    def create_comment(msg)
      public_id = find_public_id(msg)
      proposal = (Proposal.find_by_public_id(public_id) || Proposal.find(public_id)) or return
      comment_text = find_comment_text(msg)
      comment_user = find_comment_user(msg)
      if proposal.existing_observation_for(comment_user)
        # already observing, just add comment.
        proposal.comments.create(comment_text: comment_text, user: comment_user)
      else
        # yes, user adds self as observer, which also generates comment
        proposal.add_observer(comment_user, comment_user, comment_text)
        # return most recent comment (TODO race condition here?)
        proposal.comments.last
      end
    end

    def find_public_id(msg)
      # TODO search headers

      sbj_re = /Request\ #?([\w\-]+)/
      if msg['subject'].match(sbj_re)
        return msg['subject'].match(sbj_re)[1]
      end
      fail "Failed to find public_id in msg #{msg.inspect}"
    end

    def find_comment_text(msg)
      EmailReplyParser.parse_reply(msg['text'])
    end

    def find_comment_user(msg)
      from = msg['from_email']
      User.find_by_email_address(from)
    end
  end

  class Response
    attr_accessor :type, :action, :comment

    # named action constants
    ERROR   = 0
    COMMENT = 1
    DROPPED = 2

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      @type ||= ERROR # default
    end
  end
end
