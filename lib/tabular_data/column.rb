module TabularData
  class Column
    attr_accessor :header, :formatter

    def initialize(config)
      @header = config[:header] || config[:field] # @todo use I18n as default
      @field = config[:field]
      @formatter = config[:formatter] || :none    # @todo: allow a pipeline
                                                  # @todo: configure from table
    end

    # Walk the object tree to get the field in question
    def value_in(row)
      field_components = @field.split(".")
      field_components.inject(row) do |object, field|
        object.try(field)
      end
    end
  end
end
