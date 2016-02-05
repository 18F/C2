class EmailSubscriber
  # Use open/click to run actions on email open/click
  def open(event)
    # :message and :controller keys
    ahoy = event[:controller].ahoy
    ahoy.track "Email opened", message_id: event[:message].id
  end
  def click(event)
    # same keys as above, plus :url
    ahoy = event[:controller].ahoy
    ahoy.track "Email clicked", message_id: event[:message].id, url: event[:url]
  end
end
# Activate the email hook
AhoyEmail.subscribers << EmailSubscriber.new
