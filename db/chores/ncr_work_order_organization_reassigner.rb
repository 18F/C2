module Ncr
  class WorkOrderOrganizationReassigner
    def run
      Ncr::WorkOrder.all.each do |work_order|
        code = (work_order.org_code || "").split(" ", 2)[0]

        if code
          organization = Ncr::Organization.find_or_create_by(code: code)
          work_order.update(ncr_organization: organization)
        end
      end
    end

    def unrun
      Ncr::WorkOrder.all.each do |work_order|
        if work_order.ncr_organization
          organization = work_order.ncr_organization
          code = "#{organization.code} #{organization.name}"
          work_order.update(org_code: code)
        end
      end
    end
  end
end
