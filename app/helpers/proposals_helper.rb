module ProposalsHelper
  # Used in the query template to provide a span of time in the header
  def datespan_header(start_date, end_date)
    if start_date && end_date
      # month span
      if start_date.mday == 1 && end_date == start_date + 1.month
        month_name = I18n.t('date.abbr_month_names')[start_date.month]
        "(#{month_name} #{start_date.year})"
      else
        "(#{start_date.iso8601} - #{end_date.iso8601})"
      end
    end
  end

  def diff_val(val)
    if val.is_a?(Numeric)
      format('%.2f', val)
    else
      val.inspect
    end
  end
end
