class ChangeProcurementUrgencyToInteger < ActiveRecord::Migration
  def up
    add_column :gsa18f_procurements, :tmp_urgency, :integer

    execute <<-SQL
      UPDATE gsa18f_procurements
      SET tmp_urgency = 10
      WHERE urgency = 'I need it yesterday';
    SQL

    execute <<-SQL
      UPDATE gsa18f_procurements
      SET tmp_urgency = 20
      WHERE urgency = 'I''m patient but would like w/in a week';
    SQL

    execute <<-SQL
      UPDATE gsa18f_procurements
      SET tmp_urgency = 30
      WHERE urgency = 'Whenever';
    SQL

    remove_column :gsa18f_procurements, :urgency
    rename_column :gsa18f_procurements, :tmp_urgency, :urgency
  end

  def down
    add_column :gsa18f_procurements, :tmp_urgency, :string

    execute <<-SQL
      UPDATE gsa18f_procurements
      SET tmp_urgency = 'I need it yesterday'
      WHERE urgency = 10;
    SQL

    execute <<-SQL
      UPDATE gsa18f_procurements
      SET tmp_urgency = 'I''m patient but would like w/in a week'
      WHERE urgency = 20;
    SQL

    execute <<-SQL
      UPDATE gsa18f_procurements
      SET tmp_urgency = 'Whenever'
      WHERE urgency = 30;
    SQL

    remove_column :gsa18f_procurements, :urgency
    rename_column :gsa18f_procurements, :tmp_urgency, :urgency
  end
end