class InboundMailParser
  def initialize(msg)
    @msg = msg
  end

  def proposal
    @proposal ||= find_proposal(find_public_id(msg)) or return
  end

  def comment_user
    @comment_user ||= find_comment_user(msg)
  end

  def comment_text
    @comment_text ||= find_comment_text(msg)
  end

  private

  attr_reader :msg

  def find_proposal(public_id)
    Proposal.find_by_public_id(public_id) || Proposal.find(public_id)
  end

  def find_public_id(msg)
    references = msg["headers"]["References"]
    ref_re = /<proposal-(\d+)\@.+?>/
    sbj_re = /Request\ #?([\w\-]+)/

    if references.match(ref_re)
      references.match(ref_re)[1]
    elsif msg["subject"].match(sbj_re)
      msg["subject"].match(sbj_re)[1]
    else
      fail "Failed to find public_id in msg #{msg.inspect}"
    end
  end

  def find_comment_user(msg)
    User.find_by(email_address: msg["from_email"]) || User.find_by(email_address: msg["headers"]["Sender"])
  end

  def find_comment_text(msg)
    EmailReplyParser.parse_reply(msg["text"])
  end
end
