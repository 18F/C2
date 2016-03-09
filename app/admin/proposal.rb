ActiveAdmin.register Proposal do
  actions :index, :show

  permit_params :status

  index do
    column :id
    column :status
    column :name
    column :public_id
    column :requester
    actions
  end

  action_item :reindex, only: [:show] do
    link_to "Re-index", reindex_admin_proposal_path(proposal), "data-method" => :post, title: "Re-index this proposal"
  end

  member_action :reindex, method: :post do
    resource.delay.reindex
    flash[:alert] = "Re-index scheduled!"
    redirect_to admin_proposal_path(resource)
  end
end
