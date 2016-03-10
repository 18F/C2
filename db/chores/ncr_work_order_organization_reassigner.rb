module Ncr
  class WorkOrderOrganizationReassigner
    def run
      Ncr::WorkOrder.all.each do |work_order|
        code = (work_order.org_code || "").split(" ", 2)[0]

        if code
          organization = Ncr::Organization.find_or_create_by(code: code)
          work_order.ncr_organization = organization
          work_order.save(validate: false)
        end
      end
    end

    def unrun
      Ncr::WorkOrder.all.each do |work_order|
        if work_order.ncr_organization
          organization = work_order.ncr_organization
          code = "#{organization.code} #{organization.name}"
          work_order.org_code = code
          work_order.save(validate: false)
        end
      end
    end
  end
end
