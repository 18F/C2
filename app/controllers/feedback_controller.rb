class FeedbackController < ApplicationController
  # note that index is rendered implicitly as it's just a template

  def create
    message = []
    [:bug, :context, :expected, :actually, :comments, :satisfaction, :referral].each do |key|
      if !params[key].blank?
        message << "#{key}: #{params[key]}"
      end
    end
    message = message.join("\n")
    if !message.blank?
      if current_user
        message += "\nuser: #{current_user.email_address}"
      end
      CommunicartMailer.feedback(message).deliver
    end
  end
end
