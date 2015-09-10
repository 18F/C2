class HashDiffDecorator < SimpleDelegator
  alias_method :change, :__getobj__

  def h
    ActionView::Base.new
  end

  def change_type
    change[0]
  end

  def field
    change[1]
  end

  def to_html
    h.content_tag :li do
      case change_type
      when '+' # added
        val = change[2]
        C2VersionDecorator.combine_html([
          h.content_tag(:code, field),
          " was set to ",
          h.content_tag(:code, val),
          '.'
        ])
      when '~' # modified
        prev_val = self.diff_val(change[2])
        current_val = self.diff_val(change[3])
        C2VersionDecorator.combine_html([
          h.content_tag(:code, field),
          " was changed from ",
          h.content_tag(:code, prev_val),
          " to ",
          h.content_tag(:code, current_val)
        ])
      when '-' # removed
        C2VersionDecorator.combine_html([
          h.content_tag(:code, field),
          " was removed."
        ])
      else
        change.inspect
      end
    end
  end

  protected

  def diff_val(val)
    if val.is_a?(Numeric)
      format('%.2f', val)
    else
      val.inspect
    end
  end
end
