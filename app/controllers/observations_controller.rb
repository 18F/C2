class ObservationsController < ApplicationController
  # TODO authenticate_user!
  # TODO authorize

  def index
    @proposal = self.find_proposal
    @observer = User.new
    @observation = Observation.new(user: @observer, proposal: @proposal)
  end

  def create
    proposal = self.find_proposal
    observation = proposal.add_observer(params[:observation][:user][:email_address])

    observer = observation.user
    flash[:success] = "#{observer.full_name} has been added as an observer"
    # TODO store an activity comment
    redirect_to proposal_observations_path(proposal)
  end

  # TODO allow them to be removed


  protected

  def find_proposal
    Proposal.find(params[:proposal_id])
  end
end
