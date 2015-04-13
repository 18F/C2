class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize self.proposal, :can_show!}
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

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

  def auth_errors(exception)
    redirect_to carts_path, :alert => "You are not allowed to see that cart"
  end
end
