class ApiTokenPolicy
  include ExceptionPolicy

  # ApiTokenPolicy is odd in that it doesn't _have_ a user; we're really just
  # validating the params, so that will play the role of "user" here. Further,
  # we'll be determining the api_token from the params, so the second variable
  # here is not used
  def initialize(params, record)
    super(params, record)
    @params = params
    @api_token = ApiToken.find_by(access_token: params[:cch])
  end

  def exists!
    check(!@api_token.nil?,
          "Something went wrong with the token (nonexistent)")
  end

  def not_expired!
    exists! && check(!@api_token.expires_at || @api_token.expires_at > Time.now,
                     "Something went wrong with the token (expired)")
  end

  def not_used!
    exists! && check(!@api_token.used?,
                     "Something went wrong with the token (already used)")
  end

  def correct_cart!
    exists! && check(@api_token.cart_id == @params[:cart_id].to_i,
                     "Something went wrong with the token (wrong cart)")
  end

  def valid!
    exists! && not_expired! && not_used! && correct_cart!
  end
end
