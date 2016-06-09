module Ncr
  class WorkOrdersController < ClientDataController
    # arbitrary number...number of upload fields that "ought to be enough for anybody"
    MAX_UPLOADS_ON_NEW = 10

    def new
      work_order.approving_official = suggested_approver_email
      super
    end

    def edit
      if proposal.completed?
        flash.now[:warning] = "Wait! You're about to change an approved request. Your changes will be logged and sent to approvers, and your action may require reapproval of the request."
      end

      super
    end

    protected

    def work_order
      assign_modifier
      @client_data_instance
    end

    def assign_modifier
      if @client_data_instance
        @client_data_instance.modifier = current_user
      end
    end

    def suggested_approver_email
      last_proposal = current_user.last_requested_proposal
      last_proposal.try(:client_data).try(:approving_official)
    end

    def record_changes
      ProposalUpdateRecorder.new(work_order, current_user).run
    end

    def setup_and_email_approvers(comment)
      work_order.setup_and_email_subscribers(comment)
    end

    def model_class
      Ncr::WorkOrder
    end

    def permitted_params
      Ncr::WorkOrder.permitted_params(params, work_order)
    end
  end
end
