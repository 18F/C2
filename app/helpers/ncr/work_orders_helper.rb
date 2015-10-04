module Ncr
  module WorkOrdersHelper
    def approver_options
      # @todo should this list be limited by client/something else?
      # @todo is there a better order? maybe by current_user's use?
      User.order(:email_address).pluck(:email_address)
    end

    def building_options
      custom = Ncr::WorkOrder.where.not(building_number: nil).pluck('DISTINCT building_number')
      all = custom + Ncr::BUILDING_NUMBERS
      # @todo is there a better order? maybe by current_user's use?
      all.uniq.sort
    end

    def vendor_options(vendor = nil)
      all_vendors = Ncr::WorkOrder.where.not(vendor: nil).pluck('DISTINCT vendor')
      # merge in any passed
      if vendor
        all_vendors.push(vendor)
      end
      all_vendors.uniq.sort_by(&:downcase)
    end

    def expense_type_radio_button(form, expense_type)
      content_tag :div, class: 'radio' do
        form.label :expense_type, value: expense_type do
          radio = form.radio_button(:expense_type, expense_type, 'data-filter-control' => 'expense-type', required: true)
          radio + expense_type
        end
      end
    end
  end
end
