ActiveAdmin.register User do
  actions :index, :show, :new, :create, :edit, :update

  filter :last_name
  filter :first_name
  filter :email_address
  filter :active
  filter :client_slug

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :active, :first_name, :last_name, :email_address, :client_slug, :timezone, role_ids: []

  controller do
    def create
      user = User.new(user_params)
      roles = role_ids_to_roles
      User.transaction do
        user.save!
        UserRole.create(roles.map { |role| { user: user, role: role } })
      end
      redirect_to admin_user_path(user)
    end

    def user_params
      params.require(:user).permit(:active, :first_name, :last_name, :email_address, :client_slug, :timezone)
    end

    def role_id_params
      params.require(:user).permit(role_ids: [])[:role_ids]
    end

    def role_ids_to_roles
      roles = []
      role_id_params.each do |id|
        next unless id.present?
        role = Role.find(id) or next
        roles << role
      end
      roles
    end
  end

  # /:id/edit page
  form do |f|
    f.inputs "Profile" do
      f.input :email_address
      f.input :first_name
      f.input :last_name
      f.input :active
      f.input :timezone, as: :select, collection: ActiveSupport::TimeZone.us_zones
      f.input :client_slug, as: :select, include_blank: true, collection: Proposal.client_slugs
    end
    f.inputs "Roles" do
      f.input :roles, as: :select, collection: Role.all
    end
    f.actions
  end

  # /:id page
  show do
    attributes_table do
      row :email_address
      row :first_name
      row :last_name
      row :client_slug
      row :timezone
      row :created_at
      row :active
      row :updated_at
      row("Roles") { user.roles.map(&:name).join(", ") }
    end

    panel "Proposals" do
      table_for user.proposals.order("created_at DESC") do |tbl|
        tbl.column("ID") { |proposal| link_to proposal.public_id, admin_proposal_path(proposal) }
        tbl.column("Name") { |proposal| proposal.name }
        tbl.column("Submitted") { |proposal| proposal.created_at }
        tbl.column("Status") { |proposal| proposal.status }
      end
    end
  end
end
