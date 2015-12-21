ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    section "Background Jobs" do
      now = Time.zone.now
      ul do
        li do
          jobs = Delayed::Job.where("failed_at is not null").count(:id)
          link_to "#{jobs} failing jobs", admin_jobs_path(q: { failed_at_is_not_null: true }), style: "color: red"
        end
        li do
          jobs = Delayed::Job.where("run_at <= ?", now).count(:id)
          link_to "#{jobs} late jobs", admin_jobs_path(q: { run_at_lte: now.to_s(:db) }), style: "color: hsl(40, 100%, 40%)"
        end
        li do
          jobs = Delayed::Job.where("run_at >= ?", now).count(:id)
          link_to "#{jobs} scheduled jobs", admin_jobs_path(q: { run_at_gte: now.to_s(:db) }), style: "color: green"
        end
      end
    end
  end

  action_item :reindex, only: [:index] do
    link_to "Re-index Proposals", admin_dashboard_reindex_path, "data-method" => :post,
      title: "Re-index all proposals."
  end

  page_action :reindex, method: :post do
    Proposal.delay.rebuild_index
    flash[:alert] = "Re-index scheduled!"
    redirect_to admin_dashboard_path
  end
end
