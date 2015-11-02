module Ncr
  class WorkOrdersController < UseCaseController
    # arbitrary number...number of upload fields that "ought to be enough for anybody"
    MAX_UPLOADS_ON_NEW = 10

    def new
      @model_instance.approving_official_email = self.suggested_approver_email
      super
    end

    def create
      super
    end

    def edit
      if self.proposal.approved?
        flash[:warning] = "You are about to modify a fully approved request. Changes will be logged and sent to approvers but this request will not necessarily require re-approval."
      end

      super
    end

    def update
      @model_instance.modifier = current_user

      super

      manager = Ncr::WorkOrderUpdater.new(
        work_order: @model_instance,
        model_changing: @model_changing,
        flash: flash
      )
      manager.after_update
    end

    protected

    def attribute_changes?
      super || @model_instance.approver_changed?
    end

    def model_class
      Ncr::WorkOrder
    end

    def suggested_approver_email
      last_proposal = current_user.last_requested_proposal
      last_proposal.try(:approvers).try(:first).try(:email_address) || ''
    end

    def permitted_params
      fields = Ncr::WorkOrder.relevant_fields(
        params[:ncr_work_order][:expense_type])
      if @model_instance
        fields.delete(:emergency) # emergency field cannot be edited
      end
      params.require(:ncr_work_order).permit(:project_title, :approving_official_email, *fields)
    end

    # @pre: @model_instance.approving_official_email is set
    def add_approvals
      super
      if self.errors.empty?
        @model_instance.setup_approvals_and_observers
      end
    end
  end
end
