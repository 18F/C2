module HashDiffDecorator
  class Added < HashDiffDecorator::Base
    def val
      diff_val(change[:val1])
    end

    def to_html
      combine_html([
        content_tag(:span, field),
        " was set to ",
        content_tag(:strong, val),
        "."
      ])
    end
  end
end
