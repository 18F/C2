class InboxController < ApplicationController
  include Mandrill::Rails::WebHookProcessor

  skip_before_action :authenticate_user!, only: [:create, :show]
  skip_before_action :check_disabled_client

  def handle_inbound(event_payload)
    handler = IncomingMail::Handler.new
    resp = handler.handle(event_payload)
    if resp.action == IncomingMail::Response::ERROR
      # a non-200 response means Mandrill will keep trying up to 100x.
      head 500
    elsif resp.action == IncomingMail::Response::FORWARDED
      head 200
    else
      head 200 # default tells mandrill to stop trying to send the event
    end
  end
end
