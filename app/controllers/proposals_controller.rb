class ProposalsController < ApplicationController
  include TokenAuth

  skip_before_action :authenticate_user!, only: [:approve]
  skip_before_action :check_disabled_client, only: [:approve]
  # TODO use Policy for all actions
  before_action ->{authorize proposal}, only: [:show, :cancel, :cancel_form, :history]
  before_action :needs_token_on_get, only: :approve
  before_action :validate_access, only: :approve
  helper_method :display_status
  add_template_helper ProposalsHelper
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def show
    @proposal = proposal.decorate
  end

  def index
    @CLOSED_PROPOSAL_LIMIT = 10

    @pending_data = listing.pending
    @pending_review_data = listing.pending_review
    @approved_data = listing.approved.alter_query{ |rel| rel.limit(@CLOSED_PROPOSAL_LIMIT) }
    @cancelled_data = listing.cancelled
  end

  def archive
    @proposals_data = listing.closed
  end

  def cancel_form
    @proposal = proposal.decorate
  end

  def cancel
    if params[:reason_input].present?
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
    step = proposal.existing_step_for(current_user)
    step.update_attributes!(completer: current_user)
    step.approve!
    flash[:success] = "You have approved #{proposal.public_id}."
    redirect_to proposal
  end

  def query
    query_listing = listing
    @proposals_data = query_listing.query

    @text = params[:text]
    @start_date = query_listing.start_date
    @end_date = query_listing.end_date
  end

  def history
    @container = Query::Proposal::Versions.new(proposal).container
    @container.set_state_from_params(params)
  end

  protected

  def proposal
    @cached_proposal ||= Proposal.find(params[:id])
  end

  def auth_errors(exception)
    if ['cancel','cancel_form'].include?(params[:action])
      redirect_to proposal_path, alert: exception.message
    else
      super
    end
  end

  def listing
    Query::Proposal::Listing.new(current_user, params)
  end
end
