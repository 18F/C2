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

  def valid!
    exists! && not_expired! && not_used! && correct_proposal!
  end

  def valid_and_not_delegate!
    valid! && not_delegate!
  end

  private

  def exists!
    check(
      @api_token.present?,
      "Something went wrong with the token (nonexistent)"
    )
  end

  def not_expired!
    check(!@api_token.expired?, "Something went wrong with the token (expired)")
  end

  def not_used!
    check(!@api_token.used?, "Something went wrong with the token (already used)")
  end

  def correct_proposal!
    check(
      @api_token.proposal.id == @params[:id].to_i,
      "Something went wrong with the token (wrong proposal)"
    )
  end

  def not_delegate!
    check(@api_token.user.outgoing_delegates.empty?, "You must first sign in")
  end
end
