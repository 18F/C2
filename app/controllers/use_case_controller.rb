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
    render 'form'
  end

  def create
    if self.errors.empty?
      @model_instance.save
      proposal = @model_instance.proposal
      self.initial_attachments(proposal)
      self.add_approvals()
      Dispatcher.deliver_new_proposal_emails(proposal)

      flash[:success] = "Proposal submitted!"
      redirect_to proposal
    else
      flash[:error] = errors
      render 'form'
    end
  end

  def edit
    render 'form'
  end

  def update
    @model_instance.assign_attributes(self.permitted_params)  # don't hit db yet

    @model_changing = false
    @model_instance.validate
    if self.errors.empty?
      if self.attribute_changes?
        @model_changing = true
        @model_instance.save
        flash[:success] = "Successfully modified!"
      else
        flash[:error] = "No changes were made to the request"
      end
      redirect_to proposal_path(@model_instance.proposal)
    else
      flash[:error] = self.errors
      render 'form'
    end
  end


  protected

  def attribute_changes?
    !@model_instance.changed_attributes.blank?
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

    # TODO unify with how the factories create model instances
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
      flash[:notice] = exception.message
      render 'communicarts/authorization_error', status: 403
    else
      redirect_to path, alert: exception.message
    end
  end

  def initial_attachments(proposal)
    files = params.permit(attachments: [])[:attachments] || []
    files.each do |file|
      Attachment.create(proposal: proposal, user: current_user, file: file)
    end
  end

  # Hook for adding additional approvers
  def add_approvals
  end
end
