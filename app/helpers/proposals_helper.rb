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

  def request_details_form_value(value)
    property_display_value(value)
  end

  def request_details_form_field(method, f)
    render partial: 'proposals/details/fields/' + method, locals: { method: method, f: f }
  end

  def render_field_order
    [
      { 
        order: 0,
        value: ["description"]
        style: {
          column: 1,
        },
      },
      { 
        order: -1,
        style: {
        value: ["amount"]
          column: 2,
          background: "color-card"
        },
      },
      { 
        order: -2,
        value: ["direct_pay"]
        style: {
          column: 2,
        },
      },
      { 
        order: -3,
        style: {
        value: ["vendor", "building_number", "cl_number"]
          column: 1,
          background: "color-card"
        },
      },
    ]
  end
end
