ActiveAdmin.register Role do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name

  # remove filters by association
  filter :name

  # show all users with a role on /admin/roles/:id page
  show do
    panel "Role Details" do
      attributes_table_for role do
        row :id
        row :name
        row :created_at
        row :updated_at
      end
    end

    panel "Users" do
      table_for role.users do |tbl|
        tbl.column("Email") { |user| link_to user.email_address, admin_user_path(user) }
        tbl.column("Name")  { |user| user.full_name }
        tbl.column("Client") { |user| user.client_slug }
      end
    end

    active_admin_comments
  end
end
