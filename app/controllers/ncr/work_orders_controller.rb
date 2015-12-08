module Ncr
  class WorkOrdersController < ClientDataController
    # arbitrary number...number of upload fields that "ought to be enough for anybody"
    MAX_UPLOADS_ON_NEW = 10

    def new
      work_order.approving_official_email = self.suggested_approver_email
      super
    end

    def create
      Ncr::WorkOrderValueNormalizer.new(work_order).run
      super
    end

    def edit
      @client_data_instance.approving_official_email = @client_data_instance.approvers.first.try(:email_address)

      if proposal.approved?
        flash.now[:warning] = "You are about to modify a fully approved request. Changes will be logged and sent to approvers, and this request may require re-approval, depending on the change."
      end

      super
    end

    def update
      work_order.assign_attributes(permitted_params)
      Ncr::WorkOrderValueNormalizer.new(work_order).run
      work_order.modifier = current_user

      super
    end

    protected

    def work_order
      @client_data_instance
    end

    def record_changes
      ProposalUpdateRecorder.new(work_order).run
    end

    def setup_and_email_approvers
      updater = Ncr::WorkOrderUpdater.new(
        work_order: work_order,
        flash: flash
      )
      updater.run
    end

    def attribute_changes?
      super || work_order.approver_changed?
    end

    def model_class
      Ncr::WorkOrder
    end

    def suggested_approver_email
      last_proposal = current_user.last_requested_proposal
      last_proposal.try(:approvers).try(:first).try(:email_address) || ''
    end

    def permitted_params
      fields = work_order_params

      if work_order
        fields.delete(:emergency) # emergency field cannot be edited
      end

      parse_organization_params
      params.require(:ncr_work_order).permit(*fields)
    end

    def parse_organization_params
      ncr_org_code_and_name = params[:ncr_work_order][:ncr_organization_id]

      if ncr_org_code_and_name && ncr_org_code_and_name.match(/[a-z]/i)
        ncr_org_code = ncr_org_code_and_name.match(/^(\w+)/)[1]
        ncr_org = Ncr::Organization.find_by(code: ncr_org_code)
        params[:ncr_work_order][:ncr_organization_id] = ncr_org.id
      end
    end

    def work_order_params
      Ncr::WorkOrder.relevant_fields(params[:ncr_work_order][:expense_type])
    end

    # @pre: work_order.approving_official_email is set
    def add_steps
      super
      if self.errors.empty?
        work_order.setup_approvals_and_observers
      end
    end
  end
end
