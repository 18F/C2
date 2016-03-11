# Provides a foundation for policies which raise exceptions. If a method ends
# in bang (!), but is called as a boolean (?), this will convert authorization
# exceptions into "false". It also provides a short hand for raising a
# specific exception message based on a guard condition
module ExceptionPolicy
  include ActionView::Helpers::TranslationHelper

  def initialize(user, record)
    @user = user
    @record = record
  end

  def method_missing(method_sym, *arguments, &block)
    method_str = method_sym.to_s
    if method_str.end_with?("?")
      exc_method = method_str[0..-2] + "!"
      begin
        send(exc_method, *arguments, &block)
      rescue Pundit::NotAuthorizedError
        false
      end
    else
      super
    end
  end

  def check(guard, message)
    if !guard
      # will need to replace this when a new version of pundit arrives
      caller_name = caller_locations(1, 1)[0].label
      raise Pundit::NotAuthorizedError.new(query: caller_name.to_sym, record: @record, policy: self, message: message)
    end
    guard
  end
end
