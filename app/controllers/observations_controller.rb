class ObservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_proposal
  before_action -> { authorize self.observation_for_auth }
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def create
    obs = @proposal.add_observer(observer_email, current_user, params[:observation][:reason])
    flash[:success] = "#{obs.user.full_name} has been added as an observer"
    redirect_to proposal_path(@proposal)
  end

  def destroy
    proposal = observation.proposal
    if current_user == observation.user
      redirect_path = proposals_path
    else
      redirect_path = proposal_path(proposal)
    end
    observation.destroy
    flash[:success] = "Removed Observation for #{proposal.public_id}"
    redirect_to redirect_path
  end

  protected

  def find_proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end

  def observation_for_auth
    if params[:action] == 'create'
      Observation.new(proposal: @proposal)
    else
      self.observation
    end
  end

  def observation
    @cached_observation ||= Observation.find(params[:id])
  end

  def observer_email
    params.permit(observation: { user: [:email_address] })
      .require(:observation).require(:user).require(:email_address)
  end

  def auth_errors(exception)
    render 'communicarts/authorization_error', status: 403, 
           locals: { msg: "You are not allowed to add observers to that proposal. #{exception.message}" }
  end
end
