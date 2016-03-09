class AddApprovingOfficialEmailToWorkOrders < ActiveRecord::Migration
  class Ncr::WorkOrder < ActiveRecord::Base
    has_one :proposal, as: :client_data
  end

  def up
    add_column :ncr_work_orders, :approving_official_id, :integer, index: true

    Ncr::WorkOrder.all.each do |work_order|
      if work_order.proposal
        step = work_order.proposal.individual_steps.first
        if step
          work_order.approving_official = step.user
          work_order.save(validate: false)
        end
      end
    end
  end

  def down
    remove_column :ncr_work_orders, :approving_official_id
  end
end
