class Listing
  attr_reader :columns

  def initialize(queryset, config={})
    @queryset = queryset
    @config = config
    @columns = config.fetch(:columns, []).map { |c| Column.new(c) }
  end

  # @todo filtering, paging, etc.
  def rows
    @queryset
  end

  def self.config_for_client(listing_name, client_name)
    data_path_tpl = "#{Rails.root}/config/listings/#{listing_name}/%s.yml"
    if File.exists?(data_path_tpl % client_name)
      YAML.load_file(data_path_tpl % client_name).deep_symbolize_keys
    else
      YAML.load_file(data_path_tpl % "default").deep_symbolize_keys
    end
  end

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
