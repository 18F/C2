require ::File.expand_path('authentication_error.rb',  'lib/errors')
require ::File.expand_path('approval_group_error.rb',  'lib/errors')


class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :validate_access, only: :approval_response

  rescue_from AuthenticationError do |exception|
    authentication_error(exception)
  end

  rescue_from ApprovalGroupError, :with =>   :approval_group_error

  def send_cart

    cart = Commands::Approval::InitiateCartApproval.new.perform(params)
    jcart = cart.as_json(include: {cart_items:
                                       {
                                           include: :cart_item_traits
                                       }
    })
    render json: jcart, status: 201
  end

  def approval_reply_received
    cart = Cart.where(external_id: params['cartNumber'].to_i).where(status: 'pending').first
    user = cart.approval_users.where(email_address: params['fromAddress']).first
    approval = cart.approvals.where(user_id: user.id).first
    new_status = approval_reply_received_status

    if params['comment']
      cart.comments.create(user_id: user.id, comment_text: params['comment'].strip)
    end

    Commands::Approval::UpdateFromApprovalResponse.new.perform(approval, new_status)
    render json: { message: "approval_reply_received"}, status: 200
  end

  def approval_response
    @cart = Cart.find_by(id: params[:cart_id].to_i).decorate
    @approval = @cart.approvals.where(user_id: params[:user_id]).first
    @show_comments = true

    Commands::Approval::UpdateFromApprovalResponse.new.perform(@approval, approval_response_status)
    @token.update_attributes(used_at: Time.now)
    flash[:success] = "You have successfully updated Cart #{@cart.external_id}. See the cart details below"
  end


private

  def validate_access
    @token = ApiToken.find_by(access_token: params[:cch])
    if !@token
      raise AuthenticationError.new(msg: 'something went wrong with the token (nonexistent)')
    elsif @token.expires_at && @token.expires_at < Time.now
      raise AuthenticationError.new(msg: 'something went wrong with the token (expired)')
    elsif @token.used_at
      raise AuthenticationError.new(msg: 'Something went wrong with the token. It has already been used.')
    elsif @token.user_id != params[:user_id].to_i
      raise AuthenticationError.new(msg: 'Something went wrong with the user (wrong person)')
    elsif @token.cart_id != params[:cart_id].to_i
      raise AuthenticationError.new(msg: 'Something went wrong with the cart (wrong cart)')
    end
  end

  def approval_reply_received_status
    # TODO: Refactor duplication with ComunicartMailer#approval_reply_received_email
    if params['approve'] == 'APPROVE'
      'approved'
    elsif params['disapprove'] == 'REJECT'
      'rejected'
    end
  end

  def approval_response_status
    case params[:approver_action]
    when 'approve'
      'approved'
    when 'reject'
      'rejected'
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
