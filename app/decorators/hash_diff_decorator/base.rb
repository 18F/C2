module HashDiffDecorator
  class Base < SimpleDelegator
    alias_method :change, :__getobj__

    def helpers
      ActionView::Base.new
    end

    def content_tag(*args, &block)
      helpers.content_tag(*args, &block)
    end

    def change_type
      change[0]
    end

    def field
      change[1]
    end

    def to_html
      raise "Needs to be implemented by the subclass."
    end
  end
end
