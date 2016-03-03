ActiveAdmin.register Report do
  permit_params :name, :query, :shared, :user_id
  hstore_editor

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :user
      f.input :name
      f.input :query, as: :hstore
      f.input :shared
    end
    f.actions
  end
end
