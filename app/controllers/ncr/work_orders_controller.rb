class Ncr::WorkOrdersController < ApplicationController
  # arbitrary number...number of upload fields that "ought to be enough for anybody"
  MAX_UPLOADS_ON_NEW = 10

  before_filter :authenticate_user!
  before_filter ->{authorize Ncr::WorkOrder}, only: [:new, :create]
  before_filter ->{authorize find_work_order.proposal}, only: [:edit, :update]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def new
    @model_instance = Ncr::WorkOrder.new
    @model_instance.build_proposal(flow: 'linear', requester: current_user)
    @model_instance.approving_official_email = suggested_approver_email
  end

  def create
    @model_instance = Ncr::WorkOrder.new(permitted_params)
    @model_instance.build_proposal(flow: 'linear', requester: current_user)

    if errors.empty?
      proposal = ClientDataCreator.new(@model_instance, current_user, attachment_params).run
      add_approvals
      Dispatcher.deliver_new_proposal_emails(proposal)

      flash[:success] = "Proposal submitted!"
      redirect_to proposal
    else
      flash[:error] = errors
      render :new
    end
  end

  def edit
    @model_instance = find_work_order

    if @model_instance.proposal.approved?
      flash[:warning] = "You are about to modify a fully approved request. Changes will be logged and sent to approvers but this request will not require re-approval."
    end
  end

  def update
    @model_instance = find_work_order
    @model_instance.modifier = current_user
    @model_instance.assign_attributes(permitted_params)  # don't hit db yet

    @model_changing = false
    @model_instance.validate

    if errors.empty?
      if attribute_changes?
        @model_changing = true
        @model_instance.save
        flash[:success] = "Successfully modified!"
      else
        flash[:error] = "No changes were made to the request"
      end

      redirect_to proposal_path(@model_instance.proposal)
    else
      flash[:error] = errors
      render :edit
    end

    if @model_changing
      @model_instance.setup_approvals_and_observers
      @model_instance.email_approvers
    end
  end

  private

  def find_work_order
    @find_work_order ||= Ncr::WorkOrder.find(params[:id])
  end

  def auth_errors(exception)
    path = new_ncr_work_order_path

    # prevent redirect loop
    if path == request.path
      render 'communicarts/authorization_error', status: 403, locals: { msg: exception.message }
    else
      redirect_to path, alert: exception.message
    end
  end

  def errors
    @model_instance.validate
    @model_instance.errors.full_messages
  end

  def attribute_changes?
    !@model_instance.changed_attributes.blank? || @model_instance.approver_changed?
  end

  def suggested_approver_email
    last_proposal = current_user.last_requested_proposal
    last_proposal.try(:approvers).try(:first).try(:email_address) || ''
  end

  def permitted_params
    fields = Ncr::WorkOrder.relevant_fields(params[:ncr_work_order][:expense_type])

    if @model_instance
      fields.delete(:emergency) # emergency field cannot be edited
    end

    params.require(:ncr_work_order).permit(:project_title, :approving_official_email, *fields)
  end

  def attachment_params
    params.permit(attachments: [])[:attachments] || []
  end

  def add_approvals
    if errors.empty?
      @model_instance.setup_approvals_and_observers
    end
  end
end
