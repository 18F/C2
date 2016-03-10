ActiveAdmin.setup do |config|
  config.site_title = "C2"
  config.authentication_method = :authenticate_admin_user!
  config.logout_link_path = :destroy_admin_user_session_path
  config.batch_actions = true
  config.localize_format = :long
  config.register_stylesheet "active_admin/hstore_editor.css"
  config.register_javascript "active_admin/hstore_editor.js"
  config.namespace :admin do |admin|
    admin.build_menu do |menu|
      menu.add label: "Tracking", priority: 99
    end
  end
end
