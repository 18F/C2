ActiveSupport::Notifications.subscribe('Ncr::WorkOrder.update') {|_, _, _, _, work_order|
  Dispatcher.on_proposal_update(work_order.proposal)
}
