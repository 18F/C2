if Rails.env.development? || Rails.env.test?
  require "factory_girl"

  namespace :dev do
    desc "Sample data for local development environment"
    task :prime, [:email] => ["db:setup"] do |_task, args|
      include FactoryGirl::Syntax::Methods

      email = args[:email]
      user = User.find_or_create_by!(email_address: email)
      user.update(client_slug: "ncr")
      role = Role.find_by(name: "admin")
      user.roles << role

      create_gsa_data(user)
      create_ncr_data(user)
      create_completed_proposal(user)
      create_canceled_proposal(user)
    end

    def create_gsa_data(user)
      proposal = create(:proposal, requester: user)
      create(:gsa18f_procurement, :with_steps, proposal: proposal)
    end

    def create_ncr_data(user)
      proposal = create(:proposal, requester: user)
      ncr_user = create(:user, client_slug: "ncr")
      proposal.add_observer(ncr_user)
      work_order = create(:ncr_work_order, proposal: proposal)
      work_order.setup_approvals_and_observers
      create_comment_and_attachment(proposal)
    end

    def create_comment_and_attachment(proposal)
      work_order = proposal.client_data
      step = work_order.individual_steps.first
      step.complete!
      proposal.comments.create!(
        comment_text: Faker::Hacker.say_something_smart,
        user: step.user
      )
      create(:attachment, file: temp_file, proposal: proposal, user: step.user)
    end

    def temp_file
      File.new(Rails.root.join("spec", "support", "fixtures", "icon-user.png"))
    end

    def create_completed_proposal(user)
      proposal = create(:proposal, requester: user)
      work_order = create(:ncr_work_order, proposal: proposal)
      work_order.setup_approvals_and_observers
      work_order.individual_steps.each do |step|
        step.update(status: "complete", completed_at: Time.current)
      end
      proposal.complete!
    end

    def create_canceled_proposal(user)
      proposal = create(:proposal, requester: user)
      create(:gsa18f_procurement, :with_steps, proposal: proposal)
      proposal.cancel!
    end

    def ncr_user
      @_ncr_user ||= create(:user, client_slug: "ncr")
    end
  end
end
