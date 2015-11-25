class FeedbackController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :create, :thanks]
  before_action :check_for_inactive_user

  def index
    @skip_footer = true
  end

  def create
    form_values = feedback_params
    unless form_values.empty?
      FeedbackMailer.feedback(current_user, form_values).deliver_later
    end
    redirect_to "/feedback/thanks"
  end

  def thanks
  end

  private

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

  def check_for_inactive_user
    if signed_in? && current_user.inactivated?
      reset_session
      flash[:error] = "You are not allowed to login because your account has been
      inactivated. Please contact an administrator."
    end
  end
end
