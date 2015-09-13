# a stripped-down equivalent of Draper::Decorator
class BaseDecorator < SimpleDelegator
  alias_method :object, :__getobj__

  def helpers
    ActionView::Base.new
  end

  def content_tag(*args, &block)
    helpers.content_tag(*args, &block)
  end

  def combine_html(strings)
    self.class.combine_html(strings)
  end

  def self.combine_html(strings)
    buffer = ActiveSupport::SafeBuffer.new
    strings.each { |str| buffer << str }
    buffer
  end
end
