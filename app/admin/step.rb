ActiveAdmin.register Step do
  actions :index, :show, :update, :edit

  filter :status

  permit_params :status, :completer_id, :user_id

  index do
    column :id
    column :status
    column :user
    column :created_at
    column :updated_at
    column :completed_at
    column :completer
    column :proposal
    column :position
    actions
  end

  # /:id/edit page
  form do |f|
    f.inputs "Step" do
      f.input :status, collection: %w(pending actionable completed)
      f.input :completer
      f.input :user
    end
    f.actions
  end

  # /:id page
  show do
    attributes_table do
      row :proposal
      row :status
      row :position
      row :user
      row :created_at
      row :updated_at
      row :completer
      row :completed_at
    end
  end
end
