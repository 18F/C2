# Abstract controller – requires the following methods on the subclass:
# * model_class
# * permitted_params
# * errors
class UseCaseController < ApplicationController
  before_filter :authenticate_user!


  def new
    model_instance = self.model_class.new
    self.assign_model_instance_variable(model_instance)
    render 'form'
  end

  def create
    model_instance = self.model_class.new(self.permitted_params)
    self.assign_model_instance_variable(model_instance)

    # TODO unify with how the factories create model instances
    model_instance.build_proposal(flow: 'linear', requester: current_user)

    if self.errors.empty?
      model_instance.save
      # TODO after_save

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
    self.assign_model_instance_variable(self.find_model_instance)
    render 'form'
  end

  def update
    model_instance = self.find_model_instance
    self.assign_model_instance_variable(model_instance)

    model_instance.assign_attributes(self.permitted_params)   # don't hit db yet

    if self.errors.empty?
      model_instance.save
      flash[:success] = "Proposal resubmitted!"
      redirect_to proposal_path(model_instance.proposal)
    else
      flash[:error] = self.errors
      self.assign_model_instance_variable(model_instance)
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

  def model_instance_variable_name
    self.model_class.name.demodulize.underscore
  end

  def assign_model_instance_variable(val)
    var_name = "@#{self.model_instance_variable_name}".to_sym
    instance_variable_set(var_name, val)
  end
end
