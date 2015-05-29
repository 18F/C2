# Abstract controller – requires the following methods on the subclass:
# * model_class
# * permitted_params
class UseCaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize self.proposal}, only: [:edit, :update]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors


  def new
    model_instance = self.model_class.new
    self.assign_model_instance_variables(model_instance)
    render 'form'
  end

  def create
    model_instance = self.model_class.new(self.permitted_params)
    self.assign_model_instance_variables(model_instance)

    # TODO unify with how the factories create model instances
    model_instance.build_proposal(flow: 'linear', requester: current_user)

    if self.errors.empty?
      model_instance.save

      proposal = model_instance.proposal
      Dispatcher.deliver_new_proposal_emails(proposal)

      flash[:success] = "Proposal submitted!"
      redirect_to proposal
    else
      flash[:error] = errors
      render 'form'
    end
  end

  def edit
    self.find_model_instance
    render 'form'
  end

  def update
    model_instance = self.find_model_instance
    model_instance.assign_attributes(self.permitted_params)   # don't hit db yet

    if self.errors.empty?
      model_instance.save
      flash[:success] = "Proposal resubmitted!"
      redirect_to proposal_path(model_instance.proposal)
    else
      flash[:error] = self.errors
      render 'form'
    end
  end


  protected

  def find_model_instance
    unless @model_instance
      @model_instance = self.model_class.find(params[:id])
      self.assign_model_instance_variables(@model_instance)
    end

    @model_instance
  end

  def proposal
    self.find_model_instance.proposal
  end

  def model_instance_variable_name
    self.model_class.name.demodulize.underscore
  end

  def assign_model_instance_variables(val)
    @model_instance ||= val

    var_name = "@#{self.model_instance_variable_name}".to_sym
    instance_variable_set(var_name, val)
  end

  def errors
    @model_instance.valid? # force validation
    @model_instance.errors.full_messages
  end

  def auth_errors(exception)
    url = polymorphic_url(self.model_class, action: :new, routing_type: :path)
    redirect_to url, alert: exception.message
  end
end
