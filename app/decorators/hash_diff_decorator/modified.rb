module HashDiffDecorator
  class Modified < HashDiffDecorator::Base
    def prev_val
      diff_val(change[:val1])
    end

    def current_val
      diff_val(change[:val2])
    end

    def to_html
      combine_html([
        content_tag(:span, field),
        " was changed from ",
        content_tag(:strong, prev_val),
        " to ",
        content_tag(:strong, current_val)
      ])
    end
  end
end
