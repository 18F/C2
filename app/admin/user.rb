ActiveAdmin.register User do
  actions :index, :show, :new, :create, :edit, :update

  filter :last_name
  filter :first_name
  filter :email_address
  filter :active
  filter :client_slug

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :active, :first_name, :last_name, :email_address, :client_slug, role_ids: []

  # /:id/edit page
  form do |f|
    f.inputs 'Profile' do
      f.input :email_address
      f.input :first_name
      f.input :last_name
      f.input :active
      f.input :client_slug, as: :select, include_blank: true, collection: Proposal.client_slugs
    end
    f.inputs 'Roles' do
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
      row :created_at
      row :active
      row :updated_at
      row('Roles') { user.roles.map(&:name).join(', ') }
    end

    panel "Proposals" do
      table_for user.proposals.order('created_at DESC') do |tbl|
        tbl.column('ID') { |proposal| link_to proposal.public_id, admin_proposal_path(proposal) }
        tbl.column('Name') { |proposal| proposal.name }
        tbl.column('Date') { |proposal| proposal.created_at }
        tbl.column('Status') { |proposal| proposal.status }
      end
    end
  end
end
