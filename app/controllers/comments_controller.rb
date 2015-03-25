class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @commentable = find_commentable
    @comments = @commentable.comments
  end

  def create
    commentable = find_commentable
    comment = commentable.comments.build(comment_params)
    comment.user = current_user
    if comment.save
      flash[:success] = "You successfully added a comment for #{commentable.class.name} #{commentable.id}"
    else
      flash[:error] = comment.errors.full_messages
    end

    if commentable.respond_to?(:cart)
      redirect_to commentable.cart
    else
      redirect_to commentable
    end
  end

private
  def find_commentable
    params.each do |name, val|
      if name =~ /^(.+)_id$/
        return $1.classify.constantize.find(val)
      end
    end
    nil
  end

  def comment_params
    params.require(:comment).permit(:comment_text)
  end

end
