class CommentsController < ApplicationController

  def index
    @commentable = find_commentable
    @comments = @commentable.comments
  end

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params)
    if @comment.save
      flash[:notice] = "You successfully added a comment for #{@commentable.class.name} #{@commentable.id}"
      redirect_to id: nil
    else
      raise 'something went wrong'
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