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
end
