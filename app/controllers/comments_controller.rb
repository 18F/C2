class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @proposal = self.proposal
    @comments = @proposal.comments
  end

  def create
    comment = self.proposal.comments.build(comment_params)
    comment.user = current_user
    if comment.save
      flash[:success] = "You successfully added a comment"
    else
      flash[:error] = comment.errors.full_messages
    end

    redirect_to proposal.cart
  end

  protected
  def proposal
    @cached_proposal ||= Cart.find(params[:cart_id]).proposal
  end

  def comment_params
    params.require(:comment).permit(:comment_text)
  end

end
