module TabularData
  class Container
    attr_reader :columns

    def initialize(name, config)
      @name = name
      engine = config[:engine].constantize
      @arel = ArelTables.new(engine)
      @query = @arel.add_joins(engine, config.fetch(:joins, []))
      @columns = config.fetch(:columns, []).map { |c| Column.new(@arel, c) }
      if config[:sort]
        self.set_sort(config[:sort])
      end
    end

    def alter_query
      @query = yield(@query)
      self
    end

    # @todo filtering, paging, etc.
    def rows
      @query.order(@sort)
    end

    def set_state_from_params(params)
      relevant = params.permit(tables: {@name => [:sort]})
      config = relevant.fetch(:tables, {}).fetch(@name, {})
      if config.has_key? :sort
        self.set_sort(config[:sort])
      end
      self
    end

    def sort_dir_for(col)
      if @sort && @sort.expr == col.arel_col
        @sort.direction
      end
    end

    def query_params_for_sort(params, col)
      if sort_dir_for(col) == :asc  # flip to descending
        params.deep_merge(tables: {@name => {sort: '-' + col.name}})
      else
        params.deep_merge(tables: {@name => {sort: col.name}})
      end
    end

    def self.config_for_client(container_name, client_name)
      container_yaml = YAML.load_file("#{Rails.root}/config/tables/#{container_name}.yml")
      if container_yaml.has_key?(client_name)
        container_yaml[client_name].deep_symbolize_keys
      else
        container_yaml["default"].deep_symbolize_keys
      end
    end

    protected
    def set_sort(field)
      @sort = nil
      dir = field.start_with?('-') ? :desc : :asc
      field = field.gsub(/\A-/, '')

      @columns.each do |column|
        if column.name == field && column.arel_col
          @sort = column.arel_col.send(dir)
        end
      end
    end
  end
end
