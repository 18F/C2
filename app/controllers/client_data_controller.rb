# Abstract controller - requires the following methods on the subclass
# * model_class
# * permitted_params
class ClientDataController < ApplicationController
  before_action ->{authorize model_class}, only: [:new, :create]
  before_action ->{authorize proposal}, only: [:edit, :update]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  before_action :build_client_data_instance, only: [:new, :create]
  before_action :find_client_data_instance, only: [:edit, :update]

  def new
  end

  def create
    if errors.empty?
      proposal = ClientDataCreator.new(@client_data_instance, current_user, attachment_params).run
      add_steps
      Dispatcher.deliver_new_proposal_emails(proposal)

      flash[:success] = "Proposal submitted!"
      redirect_to proposal
    else
      flash.now[:error] = errors
      render :new
    end
  end

  def edit
  end

  def update
    if errors.empty?
      if attribute_changes?
        record_changes
        @client_data_instance.save
        setup_and_email_approvers
        flash[:success] = "Successfully modified!"
      else
        flash[:error] = "No changes were made to the request"
      end
      redirect_to proposal_path(@client_data_instance.proposal)
    else
      flash[:error] = errors
      render :edit
    end
  end

  protected

  def attribute_changes?
    !@client_data_instance.changed_attributes.blank?
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

  def build_client_data_instance
    @client_data_instance = model_class.new(filtered_params)
    @client_data_instance.build_proposal(flow: 'linear', requester: current_user)
  end

  def find_client_data_instance
    @client_data_instance ||= model_class.find(params[:id])
  end

  def proposal
    find_client_data_instance.proposal
  end

  def errors
    @client_data_instance.validate
    @client_data_instance.errors.full_messages
  end

  def auth_errors(exception)
    path = polymorphic_path(model_class, action: :new)
    # prevent redirect loop
    if path == request.path
      render "authorization_error", status: 403, locals: { msg: exception.message }
    else
      redirect_to path, alert: exception.message
    end
  end

  def attachment_params
    params.permit(attachments: [])[:attachments] || []
  end

  # Hook for adding additional approvers
  def add_steps
  end
end
