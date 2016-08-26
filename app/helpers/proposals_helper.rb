module ProposalsHelper
  # Used in the query template to provide a span of time in the header
  def datespan_header(start_date, end_date)
    if start_date && end_date
      # month span
      if start_date.mday == 1 && end_date == start_date + 1.month
        month_name = I18n.t('date.abbr_month_names')[start_date.month]
        "(#{month_name} #{start_date.year})"
      else
        "(#{start_date.strftime('%Y-%m-%d')} - #{end_date.strftime('%Y-%m-%d')})"
      end
    end
  end

  def status_icon_tag(status, last_approver = false)
    base_url = root_url.gsub(/\?.*$/, "").chomp("/")
    bg_linear_image = base_url + image_path("bg_#{status}_status.gif")

    image_tag(
      base_url + image_path("icon-#{status}.png"),
      class: "status-icon #{status} linear",
      style: ("background-image: url('#{bg_linear_image}');" unless last_approver)
    )
  end

  def get_new_feature_image_tag(new_feature_date)
    if user_seen_new_features_help?(new_feature_date)
      image_tag("new_feature_icon_none.svg", alt: "No New Feature")
    else
      image_tag("new_feature_icon.svg", alt: "New Feature")
    end
  end

  def user_seen_new_features_help?(new_feature_date)
    current_user.new_features_date == new_feature_date
  end
end
