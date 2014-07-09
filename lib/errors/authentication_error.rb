class AuthenticationError < StandardError
  def initialize data
    @data = data
  end
end
