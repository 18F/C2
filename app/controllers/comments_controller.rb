class CommentsController < ApplicationController
  before_action ->{authorize proposal, :can_show!}
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors


  def create
    comment = proposal.comments.build(comment_params)
    comment.user = current_user

    if comment.save
      flash[:success] = "You successfully added a comment"
      Dispatcher.on_comment_created(comment)
    else
      flash[:error] = comment.errors.full_messages
    end

    redirect_to proposal
  end


  protected

  def proposal
    @cached_proposal ||= Proposal.find(params[:proposal_id])
  end

  def comment_params
    params.require(:comment).permit(:comment_text)
  end

  def auth_errors(exception)
    render(
      "authorization_error",
      status: 403,
      locals: { msg: "You are not allowed to see that proposal." }
    )
  end
end
