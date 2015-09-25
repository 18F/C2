class InboxController < ApplicationController
  include Mandrill::Rails::WebHookProcessor

  def handle_inbound(event_payload)
    handler = IncomingMail::Handler.new
    resp = handler.handle(event_payload)
    Rails.logger.warn(resp.inspect)
    if resp.action == IncomingMail::Response::ERROR
      # TODO do we want mandrill to keep trying on our error?
      head 500
    elsif resp.action == IncomingMail::Response::DROPPED
      head 204 # TODO does mandrill treat this like 200?
    else
      head 200 # default tells mandrill to stop trying to send the event
    end
  end
end
