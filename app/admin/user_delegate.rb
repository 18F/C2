ActiveAdmin.register UserDelegate do
  actions :index, :new, :show, :create, :destroy

  permit_params :assigner_id, :assignee_id

  form do |f|
    f.inputs "Delegate" do
      f.input :assigner, as: :select, collection: User.all.map { |user| [user.email_address, user.id] }
      f.input :assignee, as: :select, collection: User.all.map { |user| [user.email_address, user.id] }
    end

    f.actions
  end

  index do
    column :assigner
    column :assignee
    actions
  end
end
