ActiveAdmin.register ApprovalDelegate do
  actions :index, :new, :show, :create, :destroy

  permit_params :assigner_id, :assignee_id

  form do |f|
    f.inputs "Delegate" do
      f.input :assigner, as: :select, collection: User.all.map { |user| [user.email_address, user.id] }
      f.input :assignee, as: :select, collection: User.all.map { |user| [user.email_address, user.id] }
    end

    f.actions
  end

  show do
    attributes_table_for approval_delegate do
      row("Assigner id") { approval_delegate.assigner.id }
      row("Assigner email") { approval_delegate.assigner.email_address }
      row("Assignee id") { approval_delegate.assignee.id }
      row("Assignee email") { approval_delegate.assignee.email_address }
    end
  end

  index do
    column :assigner do |approval_delegate|
      approval_delegate.assigner.email_address
    end

    column :assignee do |approval_delegate|
      approval_delegate.assignee.email_address
    end

    actions
  end
end
