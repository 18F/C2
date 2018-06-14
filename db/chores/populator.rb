class Populator
  include FactoryGirl::Syntax::Methods

  def uniform_ncr_data(n: 10)
    n.times do
      create(:ncr_work_order, :with_approvers)
    end
  end

  def random_ncr_data(num_proposals: 50)
    num_proposals.times do
      requested_at = rand(3.months.ago..1.day.ago)
      proposal = create_proposal(requested_at: requested_at)
      create_work_order(proposal: proposal)
      add_comments(proposal: proposal, requested_at: requested_at)
    end
  end

  def ncr_data_for_user(email:, num_proposals: 25)
    user = User.find_by(email_address: email)

    num_proposals.times do
      proposal = create_proposal(requester: user)
      create_work_order(proposal: proposal)
      add_comments(proposal: proposal)
    end
  end

  private

  def create_proposal(requester:, requested_at: Time.zone.now)
    create(
      :proposal,
      :with_serial_approvers,
      :with_observers,
      client_slug: "ncr",
      requester: create(:user, client_slug: "ncr"),
      created_at: requested_at,
      updated_at: requested_at,
    )
  end

  def create_work_order(proposal:)
    create(
      :ncr_work_order,
      emergency: random_bool(0.1),
      proposal: proposal,
      vendor: Faker::Company.name
    )
  end

  def random_bool(pct_true = 0.5)
    rand < pct_true
  end

  def add_comments(proposal:, requested_at: Time.zone.now)
    num_comments = rand(5)
    num_comments.times do
      commented_at = rand(requested_at..Time.zone.now)

      proposal.comments.create!(
        comment_text: Faker::Hacker.say_something_smart,
        created_at: commented_at,
        updated_at: commented_at,
        user: proposal.subscribers.sample
      )
    end
  end
end
