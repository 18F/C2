module ConversationThreading
  def thread_id=(msg_id)
    # http://www.jwz.org/doc/threading.html
    headers['In-Reply-To'] = msg_id
    headers['References'] = msg_id
    # GMail-specific
    # http://stackoverflow.com/a/25435722/358804
    headers['X-Entity-Ref-ID'] = msg_id
  end
end
