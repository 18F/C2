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

  def request_detail_form field, f, proposal, client_data_instance
    "<div class='detail-wrapper'>"
      "<div class='detail-display'>"
        "<label class='detail-element'>"
          field.to_json
          # field[:value][0]
        "</label>"
        # "<span class='detail-value' id='" + field[:key] + '-' + client_data_instance.id.to_s + "'>"
          # request_details_form_value field[:value][1]
        # "</span>"
      "</div>"
      "<div class='detail-edit'>"
        render partial: field[:partial],
          locals: { f: f, proposal: proposal, client_data: client_data_instance }
      "</div>"
    "</div>"
  end
end
