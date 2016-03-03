class ReportQueryToJson < ActiveRecord::Migration
  def up
    execute "alter table reports alter column query type JSON using query::JSON"
  end

  def down
    execute "alter table reports alter column query type TEXT using query::TEXT"
  end
end
