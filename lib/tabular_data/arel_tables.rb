module TabularData
  class ArelTables
    def initialize(engine)
      @tables = {base: engine.arel_table}
    end

    def add_joins(query, joins)
      joins.each do |join_field, config|
        if config == true
          joined_tables = query.joins(join_field).join_sources
          query = query.joins(joined_tables)
          @tables[join_field] = joined_tables[-1].left
        end
      end
      query
    end

    def col(db_field)
      if db_field.include? "."
        table, field = db_field.split(".")
      else
        table = :base
        field = db_field
      end
      @tables.fetch(table.to_sym, {})[field.to_sym]
    end
  end
end
