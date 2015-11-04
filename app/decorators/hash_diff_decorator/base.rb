module HashDiffDecorator
  class Base < BaseDecorator
    alias_method :change, :__getobj__

    def change_type
      change[0]
    end

    def field
      change[1]
    end

    def to_html
      raise "Needs to be implemented by the subclass."
    end

    protected

    def diff_val(val)
      if val.nil?
        "[nil]"
      elsif val.empty?
        "[empty]"
      elsif val.is_a?(Numeric)
        format('%.2f', val)
      else
        val.inspect
      end
    end
  end
end
