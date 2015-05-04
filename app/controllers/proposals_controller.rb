class ProposalsController < ApplicationController
  include TokenAuth

  before_filter :authenticate_user!, except: :approve
  before_filter ->{authorize self.proposal}, only: :show
  before_filter :validate_access, only: :approve
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

  def approve
    proposal.approve!
    redirect_to proposal
  end

  protected
  def proposal
    @cached_proposal ||= Proposal.find params[:id]
  end
end
