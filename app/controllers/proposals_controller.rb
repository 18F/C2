class ProposalsController < ApplicationController
  include TokenAuth

  before_filter :authenticate_user!, except: :approve
  # TODO use Policy for all actions
  before_filter ->{authorize self.proposal}, only: [:show, :cancel, :cancel_form, :history]
  before_filter :needs_token_on_get, only: :approve
  before_filter :validate_access, only: :approve
  helper_method :display_status
  add_template_helper ProposalsHelper
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def show
    @proposal = self.proposal.decorate
    @show_comments = true
    @include_comments_files = true
  end

  def index
    @CLOSED_PROPOSAL_LIMIT = 10

    @pending_data = self.listing.pending
    @pending_review_data = self.listing.pending_review
    @approved_data = self.listing.approved.alter_query{ |rel| rel.limit(@CLOSED_PROPOSAL_LIMIT) }
    @cancelled_data = self.listing.cancelled
  end

  def archive
    @proposals_data = self.listing.closed
  end

  def cancel_form
    @proposal = self.proposal.decorate
  end

  def cancel
    if params[:reason_input].present?
      proposal = Proposal.find(params[:id])
      comments = "Request cancelled with comments: " + params[:reason_input]
      proposal.cancel!
      proposal.comments.create!(comment_text: comments, user: current_user)

      flash[:success] = "Your request has been cancelled"
      redirect_to proposal_path(proposal)
      Dispatcher.new.deliver_cancellation_emails(proposal, params[:reason_input])
    else
      redirect_to(
        cancel_form_proposal_path(params[:id]),
        alert: "A reason for cancellation is required. Please indicate why this request needs to be cancelled."
      )
    end
  end

  def approve
    approval = self.proposal.existing_approval_for(current_user)
    if approval.user.delegates_to?(current_user)
      # assign them to the approval
      approval.update_attributes!(user: current_user)
    end

    approval.approve!
    flash[:success] = "You have approved #{proposal.public_id}."
    redirect_to proposal
  end

  # @todo - this is acting more like an index; rename existing #index to #mine
  # or similar, then rename #query to #index
  def query
    query_listing = self.listing
    @proposals_data = query_listing.query

    @text = params[:text]
    @start_date = query_listing.start_date
    @end_date = query_listing.end_date
  end

  def history
    @container = Query::Proposal::Versions.container(self.proposal)
    @container.set_state_from_params(params)
  end

  protected

  def proposal
    @cached_proposal ||= Proposal.find params[:id]
  end

  def auth_errors(exception)
    if ['cancel','cancel_form'].include? params[:action]
      redirect_to proposal_path, :alert => exception.message
    else
      super
    end
  end

  def listing
    Query::Proposal::Listing.new(current_user, params)
  end
end
