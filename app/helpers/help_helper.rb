module HelpHelper
  def title(text)
    content_for :title, text, flush: true
  end
end
