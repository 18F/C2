# Abstract controller – requires the following methods on the subclass:
# * model_class
# * permitted_params
class UseCaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize self.model_class}, only: [:new, :create]
  before_filter ->{authorize self.proposal}, only: [:edit, :update]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  before_filter :build_model_instance, only: [:new, :create]
  before_filter :find_model_instance, only: [:edit, :update]

  def new
  end

  def create
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
  end

  def update
    if errors.empty?
      if attribute_changes?
        record_changes
        @model_instance.save
        setup_and_email_approvers
        flash[:success] = "Successfully modified!"
      else
        flash[:error] = "No changes were made to the request"
      end
      redirect_to proposal_path(@model_instance.proposal)
    else
      flash[:error] = errors
      render :edit
    end
  end

  protected

  def attribute_changes?
    !@model_instance.changed_attributes.blank?
  end

  def record_changes
  end

  def setup_and_email_approvers
  end

  def filtered_params
    if params[:action] == 'new'
      {}
    else
      permitted_params
    end
  end

  def build_model_instance
    @model_instance = self.model_class.new(filtered_params)
    @model_instance.build_proposal(flow: 'linear', requester: current_user)
  end

  def find_model_instance
    @model_instance ||= self.model_class.find(params[:id])
  end

  def proposal
    self.find_model_instance.proposal
  end

  def errors
    @model_instance.validate
    @model_instance.errors.full_messages
  end

  def auth_errors(exception)
    path = polymorphic_path(self.model_class, action: :new)
    # prevent redirect loop
    if path == request.path
      render 'communicarts/authorization_error', status: 403, locals: { msg: exception.message }
    else
      redirect_to path, alert: exception.message
    end
  end

  def attachment_params
    params.permit(attachments: [])[:attachments] || []
  end

  # Hook for adding additional approvers
  def add_approvals
  end
end
