class ObservationsController < ApplicationController
  before_action :find_proposal
  before_action -> { authorize observation_for_auth }
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def create
    observer = User.find(observation_params)
    observation = @proposal.add_observer(observer, current_user, params[:observation][:reason])
    prep_create_response_msg(observer, observation)
    respond_to_observer
  end

  def destroy
    proposal = observation.proposal
    prep_destroy_response_msg(proposal)
    DispatchFinder.run(proposal).on_observer_removed(observation.user)
    observation.destroy
    check_user_and_respond(proposal)
  end

  protected

  def find_proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end

  def observation_for_auth
    if params[:action] == "create"
      Observation.new(proposal: @proposal)
    else
      observation
    end
  end

  def observation
    @cached_observation ||= Observation.find(params[:id])
  end

  def observation_params
    params.permit(observation: { user: [:id] })
      .require(:observation).require(:user).require(:id)
  end

  def prep_create_response_msg(observer, observation)
    if observation
      flash[:success] = "#{observer.full_name} is now an observer."
      create_js_notification "success", "#{observer.full_name} is now an observer."
    else
      flash[:alert] = "#{observer.full_name} is already observing this request."
      create_js_notification "alert", "#{observer.full_name} is already observing this request."
    end
  end

  def prep_destroy_response_msg(proposal)
    create_js_notification "notice", "#{observation.user.full_name} has been removed as an observer"
    flash[:success] = "Removed Observation for #{proposal.public_id}"
  end

  def auth_errors(exception)
    render(
      "authorization_error",
      status: 403,
      locals: { msg: "You are not allowed to add observers to that proposal. #{exception.message}" }
    )
  end

  def respond_to_observer
    respond_to do |format|
      format.html { redirect_to proposal_path(@proposal) }
      @subscriber_list = SubscriberList.new(@proposal).triples
      format.js
    end
  end

  def redirect_to_observer
    respond_to do |format|
      format.html { redirect_to proposals_path }
      @redirect_path = proposals_path
      format.js { render "shared/redirect" }
    end
  end

  def check_user_and_respond(proposal)
    if !proposal.subscribers.include?(current_user)
      redirect_to_observer
    else
      respond_to_observer
    end
  end

  def create_js_notification(notice_type, content)
    @js_notification = { noticeType: notice_type, content: content }
  end
end
