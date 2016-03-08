ActiveAdmin.register ScheduledReport do
  permit_params :name, :report_id, :frequency, :user_id

  form do |f|
    f.inputs "Scheduled Report" do
      f.input :name
      f.input :report
      f.input :user
      f.input :frequency, as: :select, collection: ["daily", "weekly", "monthly"]
    end
    panel "Notes" do
      "Weekly reports are sent on Mondays. Monthly reports are sent on the first day of the month."
    end
    f.actions
  end
end
