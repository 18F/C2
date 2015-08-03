module TabularData
  class Column
    attr_accessor :name, :header, :formatter, :arel_col

    def initialize(arel_tables, config)
      @name = config[:db_field] || config[:display_field]
      @display = config[:display_field] || config[:db_field]
      @header = config[:header] || @name  # @todo: use I18n as default
      @formatter = config[:formatter] || :none    # @todo: allow a pipeline
                                                  # @todo: config from activerecord
      if config.has_key? :db_field
        @arel_col = arel_tables.col(config[:db_field])
      end
    end

    # Walk the object tree to get the field in question
    def display_value(row)
      field_components = @display.split(".")
      field_components.inject(row) do |object, field|
        object.try(field)
      end
    end
  end
end
