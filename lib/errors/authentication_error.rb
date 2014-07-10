class AuthenticationError < StandardError
  def initialize data
    @data = data
  end

  def to_s
    @data[:msg]
  end
end
