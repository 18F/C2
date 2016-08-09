# Abstract controller - requires the following methods on the subclass
# * model_class
# * permitted_params
class ClientDataController < ApplicationController
  before_action -> { authorize model_class }, only: [:new, :create]
  before_action -> { authorize proposal }, only: [:edit, :update]
  before_action :build_client_data_instance, only: [:new, :create]
  before_action :find_client_data_instance, only: [:edit, :update]
  before_action :setup_flash_manager

  def new
  end

  def create
    if errors.empty?
      create_client_data
      @flash_manager.show(flash, "success", "Proposal submitted!")
      redirect_to proposal
    else
      flash_now = FlashWithNow.new
      flash_now.show(flash, "error", errors)
      render :new
    end
  end

  def edit
  end

  def update
    @client_data_instance.assign_attributes(filtered_params)
    @client_data_instance.normalize_input(current_user)
    respond_to do |format|
      format.js do
        update_js_behavior(@client_data_instance, errors)
      end
      format.html do
        update_behavior(proposal, errors)
      end
    end
  end

  protected

  def create_client_data
    proposal = ClientDataCreator.new(@client_data_instance, current_user, attachment_params).run
    add_steps
    DispatchFinder.run(proposal).deliver_new_proposal_emails
  end

  def update_or_notify_of_no_changes
    if attribute_changes?
      comment = record_changes
      @client_data_instance.save
      setup_and_email_approvers(comment)
      @flash_manager.show(flash, "success", "Your changes have been saved and the request has been modified.")
    else
      @flash_manager.show(flash, "error", "No changes were made to the request.")
    end
  end

  def attribute_changes?
    !@client_data_instance.changed_attributes.blank?
  end

  def update_js_behavior(client_data_instance, errors)
    js_response = process_js_response(client_data_instance, errors)
    if params[:validate] == "true"
      render js: js_response_function('validate')
    else
      render js: js_response_function('respond')
    end
  end

  def update_behavior(proposal, errors)
    if errors.empty?
      update_or_notify_of_no_changes
      redirect_to proposal
    else
      @flash_manager.show(flash, "error", errors)
      render :edit
    end
  end

  def js_response_function(request_type)
    response = "c2.detailsSave.el.trigger('details-form:" + request_type + "', " + js_response.to_json + "); console.log(" + js_response.to_json + ");"
    return response
  end

  def record_changes
  end

  def setup_and_email_approvers(comment = nil)
  end

  def filtered_params
    if params[:action] == "new"
      {}
    else
      permitted_params
    end
  end

  def build_client_data_instance
    @client_data_instance = model_class.new(filtered_params)
    @client_data_instance.normalize_input(current_user)
    @client_data_instance.build_proposal(requester: current_user)
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
      render_auth_errors(exception)
    else
      redirect_to path, alert: exception.message
    end
  end

  def attachment_params
    params.permit(attachments: [])[:attachments] || []
  end

  def process_js_response(client_data_instance, errors)
    if errors.empty?
      update_or_notify_of_no_changes
      { status: "success", response: client_data_instance }
    else
      { status: "error", response: errors }
    end
  end

  def add_steps
    if errors.empty?
      @client_data_instance.initialize_steps
    end
  end

  def setup_flash_manager
    @flash_manager = @current_user.should_see_beta? ? FlashWithNow.new : FlashWithoutNow.new
  end
end
