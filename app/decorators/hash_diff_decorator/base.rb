module HashDiffDecorator
  class Base < BaseDecorator
    alias_method :change, :__getobj__

    def change_type
      change[:type]
    end

    def field
      if decorated_object && decorated_object.respond_to?(:translated_key)
        decorated_object.translated_key(change[:field])
      else
        change[:field]
      end
    end

    def to_html
      raise "Needs to be implemented by the subclass."
    end

    protected

    def decorated_object
      change[:object]
    end

    def diff_val(val)
      if val.nil?
        "[nil]"
      elsif val.is_a?(Numeric)
        diff_numeric(val)
      elsif val.try(:empty?)
        "[empty]"
      else
        val.inspect
      end
    end

    def diff_numeric(val)
      if val.is_a?(Fixnum)
        val.to_s
      elsif val.is_a?(Numeric)
        format("%.2f", val)
      end
    end
  end
end
