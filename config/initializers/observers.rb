ActiveSupport::Notifications.subscribe('Comment.create') {|_, _, _, _, comment|
  Dispatcher.on_comment_created(comment)
}
