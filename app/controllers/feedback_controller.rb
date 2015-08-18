class FeedbackController < ApplicationController
  def index
    @skip_footer = true
  end

  def create
    fields = [:email, :bug, :context, :expected, :actually, :comments, :satisfaction, :referral]
    fields = fields.select {|key| !params[key].blank?}
    form_values = fields.map {|key| [key, params[key]]}
    unless form_values.empty?
      FeedbackMailer.feedback(current_user, form_values).deliver_now
    end
    # @todo - redirect somewhere to avoid back/refresh button issues
  end
end
