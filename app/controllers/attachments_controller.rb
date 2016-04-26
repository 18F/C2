class AttachmentsController < ApplicationController
  before_action ->{authorize proposal, :can_show!}, only: [:create, :show]
  before_action ->{authorize attachment}, only: [:destroy]
  rescue_from Pundit::NotAuthorizedError, with: :auth_errors
  respond_to :json, only: [:create, :destroy]

  def create
    # binding.pry
    @attachment = proposal.attachments.build(attachments_params)

    if @attachment.save
      flash[:success] = "You successfully added a attachment"
      DispatchFinder.run(proposal).deliver_attachment_emails(@attachment)
      respond_to_attachment
      # render json: { message: "success" }, :status => 200
    else
      flash[:error] = @attachment.errors.full_messages
      respond_to_attachment
      # render json: { error: @attachment.errors.full_messages.join(',')}, :status => 400
    end
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
