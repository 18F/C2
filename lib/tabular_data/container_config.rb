module TabularData
  class ContainerConfig
    CONFIG_FILE_PATH = "#{Rails.root}/config/tables/"

    def initialize(container_name, client_name)
      @container_name = container_name
      @client_name = client_name
    end

    def settings
      container_yaml = YAML.load_file(config_file)
      key = "default"
      if container_yaml.key?(client_name)
        key = client_name
      end
      container_yaml[key].deep_symbolize_keys
    end

    private

    attr_reader :container_name, :client_name

    def config_file
      CONFIG_FILE_PATH + "#{container_name}.yml"
    end
  end
end
