class Gsa18f::ProcurementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize Gsa18f::Procurement}, only: [:new, :create]
  before_filter ->{authorize find_procurement.proposal}, only: [:edit, :update]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def new
    @model_instance = Gsa18f::Procurement.new
    @model_instance.build_proposal(flow: 'linear', requester: current_user)
  end

  def create
    @model_instance = Gsa18f::Procurement.new(permitted_params)
    @model_instance.build_proposal(flow: 'linear', requester: current_user)

    if errors.empty?
      proposal = ClientDataCreator.new(@model_instance, current_user).run
      Dispatcher.deliver_new_proposal_emails(proposal)

      flash[:success] = "Proposal submitted!"
      redirect_to proposal
    else
      flash[:error] = errors
      render :new
    end
  end

  def edit
    @model_instance = find_procurement
  end

  def update
    @model_instance = find_procurement
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
  end

  private

  def find_procurement
    @find_procurement ||= Gsa18f::Procurement.find(params[:id])
  end

  def auth_errors(exception)
    path = new_gsa18f_procurement_path

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
    !@model_instance.changed_attributes.blank?
  end

  def permitted_params
    fields = Gsa18f::Procurement.relevant_fields(
      params[:gsa18f_procurement][:recurring])
    params.require(:gsa18f_procurement).permit(:name, *fields)
  end
end
