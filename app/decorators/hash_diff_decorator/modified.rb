module HashDiffDecorator
  class Modified < HashDiffDecorator::Base
    def prev_val
      self.diff_val(change[2])
    end

    def current_val
      self.diff_val(change[3])
    end

    def to_html
      C2VersionDecorator.combine_html([
        content_tag(:code, field),
        " was changed from ",
        content_tag(:code, prev_val),
        " to ",
        content_tag(:code, current_val)
      ])
    end
  end
end
