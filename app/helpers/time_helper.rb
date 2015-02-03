module TimeHelper
  def date_with_tooltip(time)
    content_tag('span', l(time.to_date), title: l(time))
  end
end
