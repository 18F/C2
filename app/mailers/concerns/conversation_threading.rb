module ConversationThreading
  protected

  def set_thread_id(msg_id)
    # http://www.jwz.org/doc/threading.html
    headers['In-Reply-To'] = msg_id
    headers['References'] = msg_id
  end
end
