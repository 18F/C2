module HelpHelper
  def title(text)
    content_for :title, text, flush: true
  end

  def set_new_feature_date(set_it, feature_date)
    if set_it
      current_user.new_features_date = feature_date
      current_user.save
    end
  end
end
