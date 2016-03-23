module Ncr
  class WorkOrdersController < ClientDataController
    # arbitrary number...number of upload fields that "ought to be enough for anybody"
    MAX_UPLOADS_ON_NEW = 10

    def new
      work_order.approving_official = suggested_approver_email
      super
    end

    def create
      Ncr::WorkOrderValueNormalizer.new(work_order).run
      super
    end

    def edit
      if proposal.completed?
        flash.now[:warning] = "You are about to modify a fully approved request. Changes will be logged and sent to approvers, and this request may require re-approval, depending on the change."
      end

      super
    end

    def update
      work_order.assign_attributes(permitted_params)
      Ncr::WorkOrderValueNormalizer.new(work_order).run

      super
    end

    protected

    def work_order
      @client_data_instance
    end

    def suggested_approver_email
      last_proposal = current_user.last_requested_proposal
      last_proposal.try(:client_data).try(:approving_official)
    end

    def record_changes
      ProposalUpdateRecorder.new(work_order, current_user).run
    end

    def setup_and_email_approvers(comment)
      Ncr::WorkOrderUpdater.new(
        work_order: work_order,
        update_comment: comment
      ).run
    end

    def model_class
      Ncr::WorkOrder
    end

    def permitted_params
      fields = work_order_params

      if work_order
        fields.delete(:emergency) # emergency field cannot be edited
      end

      params.require(:ncr_work_order).permit(*fields)
    end

    def work_order_params
      Ncr::WorkOrderFields.new.relevant(params[:ncr_work_order][:expense_type])
    end

    def add_steps
      super
      if errors.empty?
        work_order.setup_approvals_and_observers
      end
    end
  end
end
