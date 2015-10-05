module Ncr
  class WorkOrdersController < UseCaseController
    # arbitrary number...number of upload fields that "ought to be enough for anybody"
    MAX_UPLOADS_ON_NEW = 10

    def new
      @model_instance.approving_official_email = self.suggested_approver_email
      super
    end

    def create
      @model_instance.approving_official_email = params[:approver_email]
      super
    end

    def edit
      if self.proposal.approved?
        flash[:warning] = "You are about to modify a fully approved request. Changes will be logged and sent to approvers but this request will not require re-approval."
      end

      super
    end

    def update
      # TODO remove need for this
      @model_instance.approving_official_email = params[:approver_email]
      @model_instance.modifier = current_user

      super

      if @model_changing
        # TODO remove need for this
        @model_instance.setup_approvals_and_observers(@model_instance.approving_official_email)
        @model_instance.email_approvers
      end
    end

    protected

    def attribute_changes?
      # TODO remove need for passing in the approver_email
      super || @model_instance.approver_changed?(@model_instance.approving_official_email)
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
      params.require(:ncr_work_order).permit(:project_title, *fields)
    end

    def errors
      results = super
      if @model_instance.approving_official_email.blank? && !@model_instance.approver_email_frozen?
        results += ["Approver email is required"]
      end
      results
    end

    # @pre: @model_instance.approving_official_email is set
    def add_approvals
      super
      if self.errors.empty?
        # TODO remove need for passing in the approver_email
        @model_instance.setup_approvals_and_observers(@model_instance.approving_official_email)
      end
    end
  end
end
