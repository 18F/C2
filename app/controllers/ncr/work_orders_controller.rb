module Ncr
  class WorkOrdersController < ApplicationController
    before_filter :authenticate_user!
    before_filter :redirect_if_cart_cant_be_edited, only: [:edit, :update]

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
      @approver_email = params[:approver_email]
      @work_order = self.work_order
      @work_order.update(permitted_params)

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

    def redirect_if_cart_cant_be_edited
      if self.cart.approved?
        redirect_to new_ncr_work_order_path, :alert => "That proposal's already approved. New proposal?"
      elsif self.cart.requester != current_user
        redirect_to new_ncr_work_order_path, :alert => 'You cannot restart that proposal'
      end
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

  end
end
