class FeedbackController < ApplicationController
  def index
    @skip_footer = true
  end

  def create
    form_values = self.feedback_params
    unless form_values.empty?
      CommunicartMailer.feedback(current_user, form_values).deliver_later
    end
    # @todo - redirect somewhere to avoid back/refresh button issues
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
