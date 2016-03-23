module Ncr
  class WorkOrderDecorator < Draper::Decorator
    delegate_all

    EMERGENCY_APPROVER_EMAIL = "Emergency - Verbal Approval"
    NO_APPROVER_FOUND = "No Approver Found"

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

    def top_email_field
      object.description
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

    def rwa_field
      [translated_key("rwa_number"), object.rwa_number]
    end

    def work_order_ticket_number
      [translated_key("code"), object.code]
    end

    def direct_pay_field
      [translated_key("direct_pay"), object.direct_pay]
    end

    def translated_key(key)
      I18n.t("decorators.ncr/work_order.#{key}")
    end
  end
end
