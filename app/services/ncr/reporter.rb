module Ncr
  class Reporter
    def self.proposal_public_url(proposal)
      Rails.application.routes.url_helpers.url_for(
        controller: "proposals",
        action: "show",
        id: proposal.id,
        host: AppParamCredentials.default_url_host
      )
    end

    def self.make_csv_row(proposal)
      [
        proposal_public_url(proposal),
        proposal.requester.email_address,
        proposal.client_data.decorate.current_approver_email_address,
        proposal.client_data.cl_number,
        proposal.client_data.function_code,
        proposal.client_data.soc_code,
        proposal.created_at,
        proposal.final_completed_date,
        proposal.total_completion_days
      ]
    end

    def self.final_step_label(proposal)
      if proposal
        proposal.decorate.final_step_label
      else
        "Final Step Completed"
      end
    end

    def self.as_csv(proposals)
      CSV.generate do |csv|
        csv << ["URL", "Requester", "Approver", "CL", "Function Code", "Soc Code", "Created", final_step_label(proposals.first), "Duration"]
        proposals.each do |p|
          csv << make_csv_row(p.decorate)
        end
      end
    end

    def self.proposals_pending_approving_official
      Proposal.pending
        .where(client_data_type: "Ncr::WorkOrder")
        .select { |p| p.individual_steps.pluck(:status)[0] == "actionable" }
    end

    def self.proposals_pending_budget
      Proposal.pending
        .where(client_data_type: "Ncr::WorkOrder")
        .select { |p| p.individual_steps.pluck(:status).last == "actionable" }
        .sort_by { |pr| pr.client_data.expense_type }
    end

    def build_fiscal_year_report_string(year)
      completed_work_orders = Ncr::WorkOrder.completed.for_fiscal_year(year)

      CSV.generate do |csv|
        add_fiscal_year_report_headers(csv)
        add_fiscal_year_report_body(csv, completed_work_orders)
      end
    end

    private

    def add_fiscal_year_report_headers(csv)
      csv << [
        "Id",
        "Amount",
        "Date Completed",
        "Org Code",
        "CL#",
        "Budget Activity",
        "SOC",
        "Function Code",
        "Building #",
        "Vendor",
        "Description",
        "Requestor",
        "Approver"
      ]
    end

    def add_fiscal_year_report_body(csv, work_orders)
      work_orders.each do |work_order|
        add_fields(csv, work_order)
      end
    end

    def add_fields(csv, work_order)
      csv << [
        work_order.proposal.public_id,
        work_order.amount,
        find_completed_at(work_order),
        work_order.organization_code_and_name,
        work_order.cl_number,
        work_order.expense_type,
        work_order.soc_code,
        work_order.function_code,
        work_order.building_number,
        work_order.vendor,
        work_order.description,
        work_order.proposal.requester.full_name,
        find_completed_at(work_order)
      ]
    end

    def find_approver_name(work_order)
      if work_order.approving_official.present?
        work_order.approving_official.full_name
      else
        "no approver listed"
      end
    end

    def find_completed_at(work_order)
      if work_order.proposal.steps.last.present?
        work_order.proposal.steps.last.completed_at
      else
        "no approvals"
      end
    end
  end
end
