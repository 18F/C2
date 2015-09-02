class ObservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_proposal
  before_action -> { authorize self.observation_for_auth }
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def create
    observation = @proposal.add_observer(observer_email, current_user, params[:observation][:reason])
    Dispatcher.on_observer_added(observation, params[:observation][:reason])
    observer = observation.user
    flash[:success] = "#{observer.full_name} has been added as an observer"
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

  def auth_errors(_exception)
    redirect_to proposals_path, alert: "You are not allowed to add observers to that proposal"
  end
end
