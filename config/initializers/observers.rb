ActiveSupport::Notifications.subscribe('Comment.create') {|_, _, _, _, comment|
  if comment.commentable_type == 'Cart'
    Dispatcher.on_cart_comment_created(comment)
  end
}
