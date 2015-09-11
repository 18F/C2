module HashDiffDecorator
  class Added < HashDiffDecorator::Base
    def val
      diff_val(change[2])
    end

    def to_html
      C2VersionDecorator.combine_html([
        content_tag(:code, field),
        " was set to ",
        content_tag(:code, val),
        '.'
      ])
    end
  end
end
