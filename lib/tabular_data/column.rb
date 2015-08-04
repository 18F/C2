module TabularData
  class Column
    attr_accessor :name, :header, :formatter, :sort_dir

    def initialize(config, name, qualified_name)
      @name = name.to_s
      @display_field = config[:display] || config[:db] || @name
      @header = config[:header] || @name.titleize  # @todo: user I18n as default
      @formatter = config[:formatter] || :none    # @todo: allow a pipeline
                                                  # @todo: config from activerecord
      unless config[:virtual]
        @expr = Arel.sql("(#{config[:db] || qualified_name})")
      end
    end

    def can_sort?
      !!@expr
    end

    def sort(dir)
      if self.can_sort?
        @sort_dir = dir
        @expr.send(dir)
      end
    end

    # Walk the object tree to get the field in question
    def display(row)
      field_components = @display_field.split(".")
      field_components.inject(row) do |object, field|
        object.try(field)
      end
    end
  end
end
