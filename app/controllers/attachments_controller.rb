class AttachmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter ->{authorize self.proposal, :can_show!}
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors

  def create
    attachment = self.proposal.attachments.build(attachments_params)
    attachment.user = current_user
    if attachment.save
      flash[:success] = "You successfully added a attachment"
    else
      flash[:error] = attachment.errors.full_messages
    end

    redirect_to proposal.cart
  end

  protected
  def proposal
    @cached_proposal ||= Cart.find(params[:cart_id]).proposal
  end

  def attachments_params
    params.require(:attachment).permit(:file)
  end

  def auth_errors(exception)
    redirect_to carts_path, :alert => "You are not allowed to add an attachment to that proposal"
  end
end
