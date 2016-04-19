ActiveAdmin.register Proposal do
  actions :index, :show

  permit_params :status

  filter :client_data_type
  filter :status
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :status
    column :name
    column :public_id
    column :requester
    actions
  end

  # /:id page
  show do
    attributes_table do
      row :id
      row :public_id
      row :name
      row :status
      row :requester
      row :created_at
      row :updated_at
    end

    panel "Steps" do
      table_for proposal.individual_steps do |tbl|
        tbl.column("Position") { |step| link_to step.position, admin_step_path(step) }
        tbl.column("User") { |step| step.user }
        tbl.column("Status") { |step| step.status }
        tbl.column("Created") { |step| step.created_at }
        tbl.column("Updated") { |step| step.updated_at }
        tbl.column("Completer") { |step| step.completer }
        tbl.column("Completed") { |step| step.completed_at }
      end
    end
  end

  action_item :reindex, only: [:show] do
    link_to "Re-index", reindex_admin_proposal_path(proposal), "data-method" => :post, title: "Re-index this proposal"
  end

  action_item :fully_complete, only: [:show] do
    link_to "Complete", fully_complete_admin_proposal_path(proposal), "data-method" => :post, title: "Fully complete this proposal"
  end

  action_item :fully_complete_no_email, only: [:show] do
    link_to "Complete without notifications", fully_complete_no_email_admin_proposal_path(proposal), "data-method" => :post, title: "Fully complete this proposal without sending notifications to affected subscribers"
  end

  member_action :reindex, method: :post do
    resource.delay.reindex
    flash[:alert] = "Re-index scheduled!"
    redirect_to admin_proposal_path(resource)
  end

  member_action :fully_complete, method: :post do
    resource.fully_complete!(current_user)
    flash[:alert] = "Completed!"
    redirect_to admin_proposal_path(resource)
  end

  member_action :fully_complete_no_email, method: :post do
    resource.fully_complete!(current_user, true)
    flash[:alert] = "Completed!"
    redirect_to admin_proposal_path(resource)
  end
end
