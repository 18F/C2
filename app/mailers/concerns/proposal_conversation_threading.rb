module ProposalConversationThreading
  extend ActiveSupport::Concern

  def assign_threading_headers(proposal)
    msg_id = "<proposal-#{proposal.id}@#{EnvCredentials.default_url_host}>"
    self.thread_id = msg_id
  end

  def thread_id=(msg_id)
    # http://www.jwz.org/doc/threading.html
    headers["In-Reply-To"] = msg_id
    headers["References"] = msg_id
    # GMail-specific
    # http://stackoverflow.com/a/25435722/358804
    headers["X-Entity-Ref-ID"] = msg_id
  end
end
