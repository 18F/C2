module TabularData
  class Container
    attr_reader :columns, :frozen_sort

    def initialize(name, config)
      @name = name
      # useful if the sort is set via alter_query
      @frozen_sort = config.fetch(:frozen_sort, false)
      self.init_query(config[:engine].constantize, config.fetch(:joins, []))
      self.init_columns(config.fetch(:column_configs, {}), config.fetch(:columns, {}))
      self.set_sort(config[:sort])
    end

    def alter_query
      @query = yield(@query)
      self
    end

    # @todo filtering, paging, etc.
    def rows
      return @rows if @rows
      results = @query
      if @sort && !@frozen_sort
        results = results.order(@sort)
      end
      results
    end

    def rows=r
      @rows = r
    end

    def set_state_from_params(params)
      relevant = params.permit(tables: {@name => [:sort]})
      config = relevant.fetch(:tables, {}).fetch(@name, {}) || {}
      if config.has_key? :sort
        self.set_sort(config[:sort])
      end
      self
    end

    def sort_params(original_params, col)
      if col.sort_dir == :asc   # flip to descending
        original_params.deep_merge(tables: {@name => {sort: '-' + col.name}})
      else
        original_params.deep_merge(tables: {@name => {sort: col.name}})
      end
    end

    def self.config_for_client(container_name, client_name)
      # TODO load once
      filename = "#{Rails.root}/config/tables/#{container_name}.yml"
      container_yaml = YAML.load_file(filename)
      key = "default"
      if container_yaml.has_key?(client_name)
        key = client_name
      end
      container_yaml[key].deep_symbolize_keys
    end

    def set_sort(field)
      field = field || ''
      dir = field.start_with?('-') ? :desc : :asc
      field = field.gsub(/\A-/, '')

      @columns.each do |column|
        if column.name == field && !@frozen_sort
          @sort = column.sort(dir)
        else
          column.sort(nil)
        end
      end
    end

    protected

    def init_query(engine, joins)
      @query = engine.all()     # convert into a query
      joins.each do |name, config|
        if config == true
          join_tables = engine.joins(name).join_sources
          join_tables[-1].left.table_alias = name   # alias the table
          @query = @query.joins(join_tables).includes(name)
        else  # String config
          @query = @query.joins(config)
        end
      end
    end

    def init_columns(config, order)
      column_hash = {}
      config.map do |name, col_config|
        if col_config == true   # short hand for "no configuration"
          col_config = {}
        end
        qualified_name = "#{@query.table_name}.#{name}"
        column_hash[name] = Column.new(name, qualified_name, col_config)
      end
      @columns = order.map{|name| column_hash[name.to_sym]}
    end
  end
end
