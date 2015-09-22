class FeedbackController < ApplicationController
  def index
    @skip_footer = true
  end

  def create
    form_values = self.feedback_params
    unless form_values.empty?
      FeedbackMailer.feedback(current_user, form_values).deliver_later
    end
    redirect_to :thanks
  end

  def thanks
  end

  protected

  def feedback_params
    params.permit(
      :email,
      :bug,
      :context,
      :expected,
      :actually,
      :comments,
      :satisfaction,
      :referral
    ).reject { |_key, val| val.blank? }
  end
end
