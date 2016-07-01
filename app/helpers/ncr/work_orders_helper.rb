module Ncr
  module WorkOrdersHelper
    def scoped_approver_options(ineligible_approvers = [])
      User.active.where(client_slug: "ncr").order(:email_address) -
        Ncr::WorkOrder.all_system_approvers -
        ineligible_approvers
    end

    def building_options
      custom = Ncr::WorkOrder.where.not(building_number: nil).pluck("DISTINCT building_number")
      all = custom + Ncr::BUILDING_NUMBERS
      all.uniq.sort.map { |building| { name: building } }
    end

    def organization_options
      Ncr::Organization.all.map do |org|
        { name: org.code_and_name, id: org.id }
      end
    end

    def vendor_options(vendor = nil)
      all_vendors = Ncr::WorkOrder.where.not(vendor: nil).pluck("DISTINCT vendor")
      if vendor
        all_vendors.push(vendor)
      end
      all_vendors.uniq.sort_by(&:downcase).map { |vendor_name| { name: vendor_name } }
    end

    def expense_type_radio_button(form, expense_type, disabled = false)
      content_tag :div, class: "radio" do
        form.label :expense_type, value: expense_type do
          radio = form.radio_button(:expense_type, expense_type, "data-filter-control" => "expense-type", required: true, disabled: disabled)
          radio + expense_type
        end
      end
    end
  end
end
