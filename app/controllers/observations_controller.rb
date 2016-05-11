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
    DispatchFinder.run(proposal).on_observer_removed(observation.user)
    observation.destroy
    flash[:success] = "Removed Observation for #{proposal.public_id}"
    if current_user == observation.user
      redirect_to proposals_path
    else
      respond_to_observer
    end
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
      flash[:success] = "#{observer.full_name} has been added as an observer"
    else
      flash[:alert] = "#{observer.email_address} is already an observer for this request"
    end
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
end
