module Ncr
  class WorkOrdersController < ApplicationController
    before_filter :authenticate_user!
    before_filter ->{authorize self.work_order.proposal}, only: [:edit, :update] 
    rescue_from Pundit::NotAuthorizedError, with: :auth_errors

    def new
      @work_order = Ncr::WorkOrder.new
      @approver_email = self.suggested_approver_email
      render 'form'
    end

    def create
      @approver_email = params[:approver_email]
      @work_order = Ncr::WorkOrder.new(permitted_params)

      if self.errors.empty?
        @work_order.save
        cart = @work_order.init_and_save_cart(
          @approver_email, current_user)
        flash[:success] = "Proposal submitted!"
        redirect_to cart_path(cart)
      else
        flash[:error] = errors
        render 'form'
      end
    end

    def edit
      @work_order = self.work_order
      @approver_email = self.cart.ordered_approvals.first.user.email_address
      render 'form'
    end

    def update
      @work_order = self.work_order
      @work_order.update(permitted_params)
      @approver_email = params[:approver_email]

      if self.errors.empty?
        cart = self.cart
        @work_order.save
        @work_order.update_cart(@approver_email, cart)
        flash[:success] = "Proposal resubmitted!"
        redirect_to cart_path(cart)
      else
        flash[:error] = errors
        render 'form'
      end
    end

    protected

    def suggested_approver_email
      last_cart = current_user.last_requested_cart
      last_cart.try(:approvers).try(:first).try(:email_address) || ""
    end

    def work_order
      @work_order ||= Ncr::WorkOrder.find(params[:id])
    end
    def cart
      self.work_order.proposal.cart
    end

    def permitted_params
      fields = Ncr::WorkOrder.relevant_fields(
        params[:ncr_work_order][:expense_type])
      params.require(:ncr_work_order).permit(:name, *fields)
    end

    protected
    def errors
      errors = []
      if @approver_email.blank?
        errors = errors << "Approver email is required"
      end
      if !@work_order.valid?
        errors = errors + @work_order.errors.full_messages
      end
      errors
    end

    def auth_errors(exception)
      if exception.query == :not_approved?
        message = "That proposal's already approved. New proposal?"
      else
        message = "You cannot restart that proposal"
      end
      redirect_to new_ncr_work_order_path, :alert => message
    end

  end
end
