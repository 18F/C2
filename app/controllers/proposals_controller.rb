class ProposalsController < ApplicationController
  include TokenAuth

  before_filter :authenticate_user!, except: :approve
  before_filter ->{authorize self.proposal}, only: [:show, :cancel]
  before_filter :needs_token_on_get, only: :approve
  before_filter :validate_access, only: :approve
  helper_method :display_status
  add_template_helper ProposalsHelper

  def show
    @proposal = self.proposal.decorate
    @show_comments = true
    @include_comments_files = true
  end

  def index
    @proposals = self.chronological_proposals
    @CLOSED_PROPOSAL_LIMIT = 10
  end

  def archive
    @proposals = self.chronological_proposals.closed
  end

  def cancel_form
    @proposal = self.proposal.decorate
  end

  def cancel
    raise 'Do something inside the cancel action'
  end


  def approve
    approval = self.proposal.approval_for(current_user)
    if approval.user.delegates_to?(current_user)
      # assign them to the approval
      approval.update_attributes!(user: current_user)
    end

    approval.approve!
    flash[:success] = "You have approved #{proposal.public_identifier}."
    redirect_to proposal
  end

  # @todo - this is acting more like an index; rename existing #index to #mine
  # or similar, then rename #query to #index
  def query
    @proposals = self.proposals
    @start_date = self.param_date(:start_date)
    @end_date = self.param_date(:end_date)
    @text = params[:text]

    if @start_date
      @proposals = @proposals.where('created_at >= ?', @start_date)
    end
    if @end_date
      @proposals = @proposals.where('created_at < ?', @end_date)
    end
    if @text
      @proposals = ProposalSearch.new(@proposals).execute(@text)
    else
      @proposals = @proposals.order('created_at DESC')
    end
    # TODO limit/paginate results
  end

  protected

  def proposal
    @cached_proposal ||= Proposal.find params[:id]
  end

  def proposals
    policy_scope(Proposal)
  end

  def chronological_proposals
    self.proposals.order('created_at DESC')
  end
end
