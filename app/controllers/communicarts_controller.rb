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
    approval = cart.approvals.find_by(user_id: user_id) 

    case params[:approver_action]
    when 'approve'
      current_status = approval.status  
      approval.approve!
      if approval.status == 'rejected'
        flash[:success] = "You have already rejected Cart #{cart.public_identifier}."
      elsif current_status == approval.status
        flash[:success] = "You have already #{params[:approver_action]}d Cart #{cart.public_identifier}."
      else  
        flash[:success] = "You have approved Cart #{cart.public_identifier}."
      end
    when 'reject'
      current_status = approval.status
      approval.reject!
      if current_status == approval.status
        flash[:success] = "You have already #{action}d Cart #{cart.public_identifier}."
      else
        flash[:success] = "You have rejected Cart #{cart.public_identifier}."
      end
    end

    if @token
      @token.update_attribute(:used_at, Time.now)
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
    elsif @token.used_at
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
