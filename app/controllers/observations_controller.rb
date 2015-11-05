class ObservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_proposal
  before_action -> { authorize self.observation_for_auth }
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def create
    obs = @proposal.add_observer(observer_email, current_user, params[:observation][:reason])
    prep_create_response_msg(obs)
    redirect_to proposal_path(@proposal)
  end

  def destroy
    self.observation.destroy
    flash[:success] = "Deleted Observation"
    redirect_to proposal_path(self.observation.proposal_id)
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

  def prep_create_response_msg(obs)
    if obs 
      flash[:success] = "#{obs.user.full_name} has been added as an observer"
    else
      flash[:alert] = "#{observer_email} is already an observer for this request"
    end
  end

  def auth_errors(exception)
    render 'communicarts/authorization_error', status: 403, 
           locals: { msg: "You are not allowed to add observers to that proposal. #{exception.message}" }
  end
end
