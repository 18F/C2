# a stripped-down equivalent of Draper::Decorator
class BaseDecorator < SimpleDelegator
  alias_method :object, :__getobj__

  def helpers
    ActionView::Base.new
  end

  def content_tag(*args, &block)
    helpers.content_tag(*args, &block)
  end
end
