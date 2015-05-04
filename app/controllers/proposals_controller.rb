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
    @proposals = policy_scope(Proposal).order('created_at DESC')
    @CLOSED_PROPOSAL_LIMIT = 10
  end

  def archive
    @proposals = policy_scope(Proposal).closed.order('created_at DESC')
  end

  # @todo - this is acting more like an index; rename existing #index to #mine
  # or similar, then rename #query to #index
  def query
    @proposals = policy_scope(Proposal).order('created_at DESC')
    @start_date = self.param_date(:start_date)
    @end_date = self.param_date(:end_date)
    if @start_date
      @proposals = @proposals.where('created_at >= ?', @start_date)
    end
    if @end_date
      @proposals = @proposals.where('created_at < ?', @end_date)
    end
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
