class AttachmentsController < ApplicationController
  before_action ->{authorize proposal, :can_show!}, only: [:create, :show]
  before_action ->{authorize attachment}, only: [:destroy]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  respond_to :js, only: [:create, :destroy]

  def create
    @attachment = proposal.attachments.build(attachments_params)
    @proposal = proposal
    if @attachment.save
      flash[:success] = "You successfully added a attachment"
      DispatchFinder.run(proposal).deliver_attachment_emails(@attachment)
    else
      flash[:error] = @attachment.errors.full_messages
    end
    respond_to_attachment
  end

  def destroy
    attachment.destroy
    flash[:success] = "Deleted attachment"
    @proposal = proposal
    respond_to do |format|
      format.js
      format.html {redirect_to proposal_path(attachment.proposal)}
    end
  end

  def show
    redirect_to attachment.url
  end

  protected

  def proposal
    @cached_proposal ||= Proposal.find(params[:proposal_id])
  end

  def attachment
    @cached_attachment ||= Attachment.find(params[:id])
  end

  def attachments_params
    if params.permit(attachment: [:file])[:attachment]
      params.permit(attachment: [:file])[:attachment].merge(user: current_user)
    end
  end

  def auth_errors(exception)
    redirect_to proposals_path, alert: "You are not allowed to add an attachment to that proposal"
  end

  def respond_to_attachment
    respond_to do |format|
      format.js
      format.html { redirect_to proposal }
    end
  end
end
