module HashDiffDecorator
  class Removed < HashDiffDecorator::Base
    def to_html
      combine_html([
        content_tag(:span, field),
        " was removed."
      ])
    end
  end
end
