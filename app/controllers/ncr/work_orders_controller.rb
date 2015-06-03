module Ncr
  class WorkOrdersController < UseCaseController
    helper_method :approver_email_frozen?


    def new
      @approver_email = self.suggested_approver_email
      super
    end

    def create
      @approver_email = params[:approver_email]

      super

      if self.errors.empty?
        @model_instance.add_approvals(@approver_email)
      end
    end

    def edit
      @approver_email = self.proposal.approvers.first.email_address
      super
    end

    def update
      @approver_email = params[:approver_email]

      super

      if self.errors.empty?
        if !self.approver_email_frozen?
          @model_instance.update_approver(@approver_email)
        end
      end
    end


    protected

    def model_class
      Ncr::WorkOrder
    end

    def suggested_approver_email
      last_proposal = current_user.last_requested_proposal
      last_proposal.try(:approvers).try(:first).try(:email_address) || ''
    end

    def approver_email_frozen?
      if @model_instance
        approval = @model_instance.approvals.first
        approval && !approval.actionable?
      else
        false
      end
    end

    def permitted_params
      fields = Ncr::WorkOrder.relevant_fields(
        params[:ncr_work_order][:expense_type])
      params.require(:ncr_work_order).permit(:project_title, *fields)
    end

    def errors
      results = super
      if @approver_email.blank? && !self.approver_email_frozen?
        results += ["Approver email is required"]
      end
      results
    end
  end
end
