ActiveSupport::Notifications.subscribe('Comment.create') {|_, _, _, _, comment|
  Dispatcher.on_comment_created(comment)
}
ActiveSupport::Notifications.subscribe('Ncr::WorkOrder.update') {|_, _, _, _, work_order|
  Dispatcher.on_proposal_update(work_order.proposal)
}
