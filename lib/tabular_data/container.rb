module TabularData
  class Container
    attr_reader :columns, :frozen_sort, :filter

    def initialize(name, config)
      @name = name
      @frozen_sort = config.fetch(:frozen_sort, false)
      @filter = config.fetch(:filter, false)
      @query = init_query(config[:engine].constantize, config.fetch(:joins, []))
      @columns = init_columns(config.fetch(:column_configs, {}), config.fetch(:columns, {}))
      set_sort(config[:sort])
    end

    def alter_query
      @query = yield(@query)
      self
    end

    def rows
      results = @query

      if @sort && !@frozen_sort
        results = results.order(@sort)
      end

      apply_filter(results)
    end

    def apply_filter(results)
      if @filter
        @filter.call(results)
      else
        results
      end
    end

    def set_state_from_params(params)
      relevant = params.permit(tables: { @name => [:sort] })
      config = relevant.fetch(:tables, {}).fetch(@name, {}) || {}

      if config.key?(:sort)
        set_sort(config[:sort])
      end

      self
    end

    def sort_params(original_params, col)
      if col.sort_dir == :asc   # flip to descending
        original_params.deep_merge(tables: { @name => { sort: '-' + col.name }})
      else
        original_params.deep_merge(tables: { @name => { sort: col.name }})
      end
    end

    private

    def set_sort(field)
      sort_field = field || ""
      direction = sort_field.start_with?("-") ? :desc : :asc
      field_name = sort_field.gsub(/\A-/, "")

      @columns.each do |column|
        if column.name == field_name && !@frozen_sort
          @sort = column.sort(direction)
        else
          column.sort(nil)
        end
      end
    end

    def init_query(engine, joins)
      query = engine.all

      joins.each do |name, config|
        if config == true
          join_tables = engine.joins(name).join_sources
          join_tables[-1].left.table_alias = name   # alias the table
          query = query.joins(join_tables).includes(name)
        else  # String config
          query = query.joins(config)
        end
      end

      query
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

      order.map{|name| column_hash[name.to_sym]}
    end
  end
end
