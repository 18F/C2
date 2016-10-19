module TabularData
  class Column
    attr_accessor :name, :formatter, :sort_dir

    def initialize(name, qualified_name, config = {})
      @config = config
      @name = name.to_s
      @display_field = config[:display] || config[:db] || @name
      unless config[:virtual]
        @db_expr = Arel.sql("(#{config[:db] || qualified_name})")
      end
    end

    def can_sort?
      @db_expr.present?
    end

    def header
      @config[:header] || @name.titleize
    end

    def formatter
      @config[:formatter] || :none
    end

    def sort(dir)
      if can_sort?
        @sort_dir = dir
        if dir
          @db_expr.send(dir)
        end
      end
    end

    # Walk the object tree to get the field in question
    def display(row)
      field_components = @display_field.split(".")
      field_components.inject(row) do |object, field|
        object.try(field) || "n/a"
      end
    end
  end
end
