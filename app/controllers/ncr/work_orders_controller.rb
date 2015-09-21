module Ncr
  class WorkOrdersController < UseCaseController
    def new
      @approver_email = self.suggested_approver_email
      super
    end

    def create
      @approver_email = params[:approver_email]
      super
    end

    def edit
      if self.proposal.approved?
        flash[:warning] = "You are about to modify a fully approved request. Changes will be logged and sent to approvers but this request will not require re-approval."
      end
      first_approver = self.proposal.approvers.first
      @approver_email = first_approver.try(:email_address)

      super
    end

    def update
      @approver_email = params[:approver_email]
      @model_instance.modifier = current_user

      super do
        unless @model_instance.emergency  # skip approvals if emergency
          @model_instance.setup_approvals_and_observers(@approver_email)

          if self.requires_budget_reapproval?
            @model_instance.restart_budget_approvals
          end

          Dispatcher.on_proposal_update(self.proposal, @model_instance.modifier)
        end
      end
    end

    protected

    def attribute_changes?
      super || @model_instance.approver_changed?(@approver_email)
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
        fields.delete(:emergency)   # emergency field cannot be edited
      end
      params.require(:ncr_work_order).permit(:project_title, *fields)
    end

    def errors
      results = super
      if @approver_email.blank? && !@model_instance.approver_email_frozen?
        results += ["Approver email is required"]
      end
      results
    end

    # @pre: @approver_email is set
    def add_approvals
      super
      if self.errors.empty?
        @model_instance.setup_approvals_and_observers(@approver_email)
      end
    end

    ## update helpers ##
    # TODO move into a standalone class

    def amount_increased?
      @model_instance.amount_changed? && (@model_instance.amount > @model_instance.amount_was)
    end

    def budget_codes_changed?
      Ncr::WorkOrder.budget_code_fields.any? do |field|
        @model_instance.send("#{field}_changed?")
      end
    end

    def budget_approver?
      @model_instance.budget_approvers.include?(current_user)
    end

    def requires_budget_reapproval?
      @model_instance.approved? && (
        self.amount_increased? || (
          self.budget_codes_changed? &&
          !self.budget_approver?
        )
      )
    end

    ####################
  end
end
