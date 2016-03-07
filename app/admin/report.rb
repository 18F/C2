ActiveAdmin.register Report do
  permit_params :name, :query, :shared, :user_id
  hstore_editor

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :user
      f.input :name
      f.input :query, as: :hstore
      f.input :shared
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :query
      row :shared
      row :user
      row :created_at
      row :updated_at
    end

    panel "Scheduled Subscriptions" do
      table_for report.subscriptions.order("created_at DESC") do |tbl|
        tbl.column("Name") { |scheduled_report| link_to scheduled_report.name, admin_scheduled_report_path(scheduled_report) }
        tbl.column("Owner") { |scheduled_report| scheduled_report.user }
        tbl.column("Freqency") { |scheduled_report| scheduled_report.frequency }
      end
    end
  end
end
