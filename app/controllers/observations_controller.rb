class ObservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_proposal
  before_action ->{authorize Observation.new(proposal: @proposal)}, only: :create
  before_action ->{authorize self.observation}, except: :create
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors


  def create
    cleaned = params.permit(observation: { user: [:email_address] })
    email = cleaned.require(:observation).require(:user).require(:email_address)
    observation = @proposal.add_observer(email)
    Dispatcher.on_observer_added(observation)

    observer = observation.user
    flash[:success] = "#{observer.full_name} has been added as an observer"
    # TODO store an activity comment
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

  def observation
    @cached_observation ||= Observation.find(params[:id])
  end

  def auth_errors(exception)
    redirect_to proposals_path, alert: "You are not allowed to add observers to that proposal"
  end
end
