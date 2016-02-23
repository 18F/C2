if Rails.env.development? || Rails.env.test?
  require "factory_girl"

  namespace :dev do
    desc "Sample data for local development environment"
    task prime: "db:setup" do
      include FactoryGirl::Syntax::Methods

      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers

      procurement = create(:gsa18f_procurement)
      procurement.add_steps
    end
  end
end
