module HashDiffDecorator
  class Removed < HashDiffDecorator::Base
    def to_html
      combine_html([
        content_tag(:code, field),
        " was removed."
      ])
    end
  end
end
