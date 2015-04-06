class ApiTokenPolicy
  include TreePolicy
  def perm_trees
    {
      is_valid?: [:exists?, :is_not_expired?, :is_not_used?, :is_correct_cart?]
    }
  end

  # ApiTokenPolicy is odd in that it doesn't _have_ a user; we're really just
  # validating the params, so that will play the role of "user" here. Further,
  # we'll be determining the api_token from the params, so the second variable
  # here is not used
  def initialize(params, _)
    @params = params
    @api_token = ApiToken.find_by(access_token: params[:cch])
  end

  def exists?
    !@api_token.nil?
  end

  def is_not_expired?
    exists? && (!@api_token.expires_at || @api_token.expires_at > Time.now)
  end

  def is_not_used?
    exists? && (!@api_token.used?)
  end

  def is_correct_cart?
    exists? && (@api_token.cart_id == @params[:cart_id].to_i)
  end

  def is_valid?
    self.test_all(:is_valid?)
  end
end
