ActiveAdmin.register Ahoy::Event do
  actions :index, :show
  menu parent: "Tracking", label: "Events"
end
