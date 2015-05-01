require ::File.expand_path('approval_group_error.rb',  'lib/errors')


class CommunicartsController < ApplicationController
  include TokenAuth

  before_filter :validate_access, only: :approval_response
  rescue_from ApprovalGroupError, with: :approval_group_error

  def send_cart
    cart = Commands::Approval::InitiateCartApproval.new.perform(params)
    jcart = cart.as_json
    render json: jcart, status: 201
  end

  def approval_response
    approval = self.proposal.approval_for(current_user)
    if approval.user.delegates_to?(current_user)
      # assign them to the approval
      approval.update_attributes!(user: current_user)
    end

    case params[:approver_action]
      when 'approve'
        approval.approve!
        flash[:success] = "You have approved #{self.proposal.public_identifier}."
      when 'reject'
        approval.reject!
        flash[:success] = "You have rejected #{self.proposal.public_identifier}."
    end

    redirect_to proposal_path(self.proposal)
  end


  protected

  def approval_group_error(error)
    render json: { message: error.to_s }, status: 400
  end

  def cart
    @cart ||= Cart.find(params[:cart_id])
  end

  def proposal
    self.cart.proposal
  end
end
