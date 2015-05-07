require ::File.expand_path('approval_group_error.rb',  'lib/errors')


class CommunicartsController < ApplicationController
  include TokenAuth

  rescue_from ApprovalGroupError, with: :approval_group_error

  def send_cart
    cart = Commands::Approval::InitiateCartApproval.new.perform(params)
    jcart = cart.as_json
    render json: jcart, status: 201
  end


  protected

  def approval_group_error(error)
    render json: { message: error.to_s }, status: 400
  end
end
