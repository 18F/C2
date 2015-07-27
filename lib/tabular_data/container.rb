module TabularData
  class Container
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

    def self.config_for_client(container_name, client_name)
      data_path_tpl = "#{Rails.root}/config/tables/#{container_name}/%s.yml"
      if File.exists?(data_path_tpl % client_name)
        YAML.load_file(data_path_tpl % client_name).deep_symbolize_keys
      else
        YAML.load_file(data_path_tpl % "default").deep_symbolize_keys
      end
    end
  end
end
