ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model

  permit_params :first_name, :last_name, :email_address, :client_slug, role_ids: []

  # /:id/edit page
  form do |f|
    f.inputs 'Profile' do
      f.input :email_address
      f.input :first_name
      f.input :last_name
      f.input :client_slug, :as => :select, :include_blank => true, :collection => Proposal.client_slugs
    end
    f.inputs 'Roles' do
      f.input :roles, :as => :select, :collection => Role.all
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
      row :updated_at
      row ('Roles') { user.roles.map(&:name).join(', ') }
    end
  end

#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end


end
