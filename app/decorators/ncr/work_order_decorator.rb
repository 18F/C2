module Ncr
  class WorkOrderDecorator < Draper::Decorator
    delegate_all

    EMERGENCY_APPROVER_EMAIL = "Emergency - Verbal Approval"
    NO_APPROVER_FOUND = "No Approver Found"

    def client_code
      "ncr"
    end

    def current_approver_email_address
      if proposal.completed?
        final_approver_email_address
      else
        pending_approver_email_address
      end
    end

    def email_display
      if object.ba80?
        base_email_fields + [rwa_field, work_order_ticket_number, direct_pay_field]
      else
        base_email_fields + [direct_pay_field]
      end
    end

    def display
      if object.ba80?
        base_fields + [rwa_field, work_order_ticket_number]
      elsif object.ba61?
        base_fields + [emergency_field]
      else
        base_fields
      end
    end

    def new_display
      %w(description expense_type emergency rwa_number work_order_code building_number ncr_organization_id vendor soc_code function_code cl_number direct_pay amount)
    end

    def top_email_field
      object.description
    end

    def translated_key(key)
      I18n.t("decorators.ncr/work_order.#{key}")
    end

    private

    def final_approver_email_address
      approver_email_address(final_approver)
    end

    def pending_approver_email_address
      approver_email_address(proposal.currently_awaiting_step_users.first)
    end

    def approver_email_address(approver)
      if approver
        approver.email_address
      elsif emergency
        EMERGENCY_APPROVER_EMAIL
      else
        NO_APPROVER_FOUND
      end
    end

    def amount_and_not_to_exceed
      if object.not_to_exceed?
        translated_key("not_to_exceed_amount")
      else
        translated_key("amount")
      end
    end

    def base_email_fields
      [
        [amount_and_not_to_exceed, object.amount],
        [translated_key("cl_number"), object.cl_number],
        [translated_key("expense_type"), object.expense_type],
        [translated_key("function_code"), object.function_code],
        [translated_key("vendor"), object.vendor],
        [translated_key("soc_code"), object.soc_code],
        [translated_key("building_number"), object.building_number],
        [translated_key("org_code"), object.organization_code_and_name]
      ]
    end

    def base_fields
      [
        [translated_key("project_title"), object.project_title],
        [translated_key("description"), object.description],
        [translated_key("approving_official"), object.approving_official],
        [amount_and_not_to_exceed, object.amount],
        [translated_key("building_number"), object.building_number],
        [translated_key("cl_number"), object.cl_number],
        [translated_key("expense_type"), object.expense_type],
        [translated_key("function_code"), object.function_code],
        [translated_key("vendor"), object.vendor],
        [translated_key("soc_code"), object.soc_code],
        [translated_key("org_code"), object.organization_code_and_name],
        direct_pay_field
      ]
    end

    def rwa_field
      [translated_key("rwa_number"), object.rwa_number]
    end

    def work_order_ticket_number
      [translated_key("work_order_code"), object.work_order_code]
    end

    def emergency_field
      [translated_key("emergency"), object.emergency]
    end

    def direct_pay_field
      [translated_key("direct_pay"), object.direct_pay]
    end
  end
end
