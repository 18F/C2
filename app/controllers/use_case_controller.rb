# Abstract controller – requires the following methods on the subclass:
# * model_class
# * permitted_params
class UseCaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize self.proposal}, only: [:edit, :update]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  before_filter :find_model_instance, only: [:edit, :update]


  def new
    @model_instance = self.model_class.new
    render 'form'
  end

  def create
    @model_instance = self.model_class.new(self.permitted_params)

    # TODO unify with how the factories create model instances
    @model_instance.build_proposal(flow: 'linear', requester: current_user)

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
    @model_instance.assign_attributes(self.permitted_params)   # don't hit db yet

    if self.errors.empty?
      @model_instance.save
      flash[:success] = "Proposal resubmitted!"
      redirect_to proposal_path(@model_instance.proposal)
    else
      flash[:error] = self.errors
      render 'form'
    end
  end


  protected

  def find_model_instance
    @model_instance ||= self.model_class.find(params[:id])
  end

  def proposal
    self.find_model_instance.proposal
  end

  def errors
    # TODO use #validate after upgrading to Rails 4.2.1+
    @model_instance.valid? # force validation
    @model_instance.errors.full_messages
  end

  def auth_errors(exception)
    url = polymorphic_url(self.model_class, action: :new, routing_type: :path)
    redirect_to url, alert: exception.message
  end

  def initial_attachments(proposal)
    files = params.permit(attachments: [])[:attachments] or []
    files.each do |file|
      Attachment.create(proposal: proposal, user: current_user, file: file)
    end
  end
  
  # Hook for adding additional approvers
  def add_approvals
  end
end
