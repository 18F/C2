class ProposalsController < ApplicationController
  include TokenAuth

  before_filter :authenticate_user!, except: :approve
  before_filter ->{authorize self.proposal}, only: [:show, :cancel, :cancel_form]
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
    @pending_data = self.proposals_container(:pending) { |p| p.pending }
    @approved_data = self.proposals_container(:approved) { |p| p.approved.limit(@CLOSED_PROPOSAL_LIMIT) }
    @cancelled_data = self.proposals_container(:cancelled) { |p| p.cancelled }
  end

  def archive
    @proposals_data = self.proposals_container(:closed) { |p| p.closed }
  end

  def cancel_form
    @proposal = self.proposal.decorate
  end

  def cancel
    if params[:reason_input].present?
      proposal = Proposal.find params[:id]
      comments = "Request cancelled with comments: " + params[:reason_input]
      proposal.cancel!
      proposal.comments.create!(comment_text: comments, user_id: current_user.id)

      flash[:success] = "Your request has been cancelled"
      redirect_to proposal_path, id: proposal.id
      Dispatcher.new.deliver_cancellation_emails(proposal)
    else
      redirect_to cancel_form_proposal_path, id: params[:id],
                                             alert: "A reason for cancellation is required.
                                                     Please indicate why this request needs
                                                     to be cancelled."
    end
  end

  def approve
    approval = self.proposal.existing_approval_for(current_user)
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
    @proposals_data = self.proposals_container(:query)

    # @todo - move all of this filtering into the TabularData::Container object
    @start_date = self.param_date(:start_date)
    @end_date = self.param_date(:end_date)
    @text = params[:text]

    if @start_date
      @proposals_data.alter_query{ |p| p.where('proposals.created_at >= ?', @start_date) }
    end
    if @end_date
      @proposals_data.alter_query{ |p| p.where('proposals.created_at < ?', @end_date) }
    end
    if @text
      @proposals_data.alter_query do |p| 
        ProposalSearch.new(p).execute(@text)
      end
    end
    # TODO limit/paginate results
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

  protected
  def proposals_container(name, &block)
    config = TabularData::Container.config_for_client("proposals", current_user.client_slug)
    container = TabularData::Container.new(name, config)
    container.alter_query { |p| policy_scope(p) }
    if block
      container.alter_query(&block)
    end
    container.set_state_from_params(params)
  end
end
