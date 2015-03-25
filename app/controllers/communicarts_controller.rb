require ::File.expand_path('authentication_error.rb',  'lib/errors')
require ::File.expand_path('approval_group_error.rb',  'lib/errors')


class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :validate_access, only: :approval_response

  rescue_from AuthenticationError do |exception|
    authentication_error(exception)
  end

  rescue_from ApprovalGroupError, with: :approval_group_error

  def send_cart
    cart = Commands::Approval::InitiateCartApproval.new.perform(params)
    jcart = cart.as_json
    render json: jcart, status: 201
  end

  def approval_response
    cart = Cart.find(params[:cart_id]).decorate
    client_data = cart.proposal.client_data_legacy
    approval = cart.approvals.find_by(user_id: user_id)
    @token ||= ApiToken.find_by(approval_id: approval.id)
    
    if !approval.pending?
      flash[:error] = "You have already logged a response for Cart #{client_data.public_identifier}"
    elsif !approval.approvable?
      flash[:error] = "Sorry. You are not allowed to approve your own request."
    else
      case params[:approver_action]
      when 'approve'
        approval.approve!
        flash[:success] = "You have approved Cart #{client_data.public_identifier}."
      when 'reject'
        approval.reject!
        flash[:success] = "You have rejected Cart #{client_data.public_identifier}."
      end
    end

    if @token && !@token.used?
      @token.use!
    end
    redirect_to cart_path(cart)
  end


  private

  def validate_access
    return if signed_in?

    @token = ApiToken.find_by(access_token: params[:cch])
    if !@token
      raise AuthenticationError.new(msg: 'something went wrong with the token (nonexistent)')
    elsif @token.expires_at && @token.expires_at < Time.now
      raise AuthenticationError.new(msg: 'something went wrong with the token (expired)')
    elsif @token.used?
      raise AuthenticationError.new(msg: 'Something went wrong with the token. It has already been used.')
    elsif @token.cart_id != params[:cart_id].to_i
      raise AuthenticationError.new(msg: 'Something went wrong with the cart (wrong cart)')
    else
      sign_in(@token.user)
    end
  end

  def user_id
    if signed_in?
      current_user.id
    else
      @token.user_id
    end
  end

  def authentication_error(e)
    flash[:error] = e.message
    redirect_to "/498.html"
  end

  def approval_group_error(error)
    render json: { message: error.to_s }, status: 400
  end
end
