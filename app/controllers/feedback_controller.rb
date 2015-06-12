class FeedbackController < ApplicationController
  # note that index is rendered implicitly as it's just a template

  def create
    fields = [:bug, :context, :expected, :actually, :comments, :satisfaction, :referral]
    fields = fields.select {|key| !params[key].blank?}
    form_values = fields.map {|key| [key, params[key]]}
    unless form_values.empty?
      CommunicartMailer.feedback(current_user, form_values).deliver
    end
  end
end
