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

  csv do
    proposal_attributes = %w(id status created_at updated_at client_data_type public_id visit_id)
    proposal_attributes.each do |proposal_attr|
      column(proposal_attr.to_sym) { |proposal| proposal.attributes[proposal_attr] }
    end
    column(:requester) { |proposal| proposal.requester.display_name }
    column(:approving_offical_name) do |proposal|
      get_user_display_name(proposal.client_data.attributes["approving_official_id"])
    end
    column(:approving_offical_email) do |proposal|
      get_user_email(proposal.client_data.attributes["approving_official_id"])
    end
    client_data_attributes.each do |client_attribute|
      column(client_attribute.to_sym) do |proposal|
        get_client_data_attribute(proposal, client_attribute)
      end
    end
    column(:attachments) do |proposal|
      get_proposal_attachments(proposal)
    end
  end
end

private

def get_proposal_attachments(proposal)
  proposal.attachments.map(&:url)
end

def client_data_attributes
  (
    Ncr::WorkOrderFields.new.relevant("BA80") +
    Ncr::WorkOrderFields.new.relevant("BA61") +
    Gsa18f::ProcurementFields.new.relevant(true) +
    Gsa18f::EventFields.new.relevant
  ).uniq
end

def get_client_data_attribute(proposal, client_attribute)
  if proposal.client_data[client_attribute]
    proposal.client_data[client_attribute]
  else
    ""
  end
end

def get_user_email(id)
  if id
    User.find(id).email_address
  else
    ""
  end
end

def get_user_display_name(id)
  if id
    User.find(id).display_name
  else
    ""
  end
end
