class ProposalsController < ApplicationController
  include TokenAuth

  skip_before_action :authenticate_user!, only: [:approve]
  skip_before_action :check_disabled_client, only: [:approve]
  # TODO use Policy for all actions
  before_action -> { authorize proposal }, only: [:show, :cancel, :cancel_form, :history]
  before_action :needs_token_on_get, only: :approve
  before_action :validate_access, only: :approve
  helper_method :display_status
  add_template_helper ProposalsHelper
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def show
    @proposal = proposal.decorate
  end

  def index
    @closed_proposal_limit = ENV.fetch("CLOSED_PROPOSAL_LIMIT", 10).to_i
    @pending_data = listing.pending
    @pending_review_data = listing.pending_review
    @approved_data = listing.approved.alter_query { |rel| rel.limit(@closed_proposal_limit) }
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
      cancel_proposal_and_send_cancellation_emails
      flash[:success] = "Your request has been cancelled"
      redirect_to proposal_path(proposal)
    else
      redirect_to(
        cancel_form_proposal_path(params[:id]),
        alert: "A reason for cancellation is required. Please indicate why this request needs to be cancelled."
      )
    end
  end

  def approve
    step = proposal.existing_or_delegated_step_for(current_user)
    step.update_attributes!(completer: current_user)
    step.approve!
    flash[:success] = "You have approved #{proposal.public_id}."
    redirect_to proposal
  end

  def query
    check_search_params
    query_listing = listing
    @proposals_data = query_listing.query

    @start_date = query_listing.start_date
    @end_date = query_listing.end_date
  end

  def download
    params[:size] = :all
    params.delete(:page)
    query_listing = listing
    @proposals_data = query_listing.query
    timestamp = Time.current.utc.strftime("%Y-%m-%d-%H-%M-%S")
    headers["Content-Disposition"] = %(attachment; filename="C2-Proposals-#{timestamp}.csv")
    headers["Content-Type"] = "text/csv"
  end

  def history
    @container = ProposalVersionsQuery.new(proposal).container
    @container.state_from_params = params
  end

  protected

  def cancel_proposal_and_send_cancellation_emails
    comments = "Request cancelled with comments: " + params[:reason_input]
    proposal.cancel!
    proposal.comments.create!(comment_text: comments, user: current_user)
    DispatchFinder.run(proposal).deliver_cancellation_emails(params[:reason_input])
  end

  def proposal
    @cached_proposal ||= Proposal.find(params[:id])
  end

  def auth_errors(exception)
    if %w(cancel cancel_form).include?(params[:action])
      redirect_to proposal_path, alert: exception.message
    else
      super
    end
  end

  def listing
    ProposalListingQuery.new(current_user, params)
  end

  def check_search_params
    @dsl = build_search_dsl
    @text = params[:text]
    @adv_search = @dsl.client_query
    build_search_query
    find_search_report
    unless valid_search_params?
      flash[:alert] = "Please enter one or more search criteria"
      redirect_to proposals_path
    end
  end

  def valid_search_params?
    @text.present? || @adv_search.present? || (params[:start_date].present? && params[:end_date].present?)
  end

  def find_search_report
    if params[:report]
      @report = Report.find params[:report]
    end
  end

  def build_search_dsl
    ProposalSearchDsl.new(
      params: params,
      current_user: current_user,
      query: params[:text],
      client_data_type: current_user.client_model.to_s
    )
  end

  def build_search_query
    @search_query = { "humanized" => @dsl.humanized_query_string }
    if @text.present?
      @search_query["text"] = @text
    end
    if @adv_search.present?
      @search_query[current_user.client_model_slug] = @adv_search.to_h
    end
  end
end
