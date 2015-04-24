class ProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize self.proposal}, only: [:show]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  helper_method :display_status

  def show
    @proposal = self.proposal.decorate
    @show_comments = true
    @include_comments_files = true
  end

  def index
    @proposals = policy_scope(Proposal).where(requester: current_user).order(
      'created_at DESC')
    @CLOSED_PROPOSAL_LIMIT = 10
  end

  def archive
    @closed_proposals = policy_scope(Proposal).where(
      requester: current_user).closed.order('created_at DESC')
  end

  protected
  def proposal
    @cached_proposal ||= Proposal.find params[:id]
  end

  def auth_errors(exception)
    redirect_to proposals_path,
      alert: "You are not allowed to see that proposal"
  end
end
