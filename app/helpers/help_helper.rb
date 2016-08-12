module HelpHelper
  def title(text)
    content_for :title, text, flush: true
  end

  def set_new_feature_cookie(set_feature_cookie, feature_date)
    if set_feature_cookie
      cookies[feature_date] = "true"
    end
  end
end
