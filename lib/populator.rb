module Populator
  # singleton
  # https://practicingruby.com/articles/ruby-and-the-singleton-pattern-dont-get-along
  extend self

  def uniform_ncr_data(n=10)
    n.times do |i|
      FactoryGirl.create(:ncr_work_order, :with_approvers)
    end
  end

  def random_bool(pct_true=0.5)
    rand < pct_true
  end

  def random_ncr_data(num_proposals=50)
    # all of the hard-coded numbers within here are fairly arbitrary

    num_proposals.times do |i|
      requested_at = rand(3.months.ago..1.day.ago)

      # TODO all of these things should have the same created_at/updated_at... use Timecop
      proposal = FactoryGirl.create(:proposal,
        :with_approvers,
        :with_observers,
        created_at: requested_at,
        updated_at: requested_at
      )

      work_order = FactoryGirl.create(:ncr_work_order,
        emergency: random_bool(0.1),
        proposal: proposal,
        vendor: Faker::Company.name
      )

      unless work_order.emergency
        # TODO randomly approve approvals and proposals at different times
      end

      users = proposal.users

      # add comments
      num_comments = rand(5)
      num_comments.times do |j|
        commented_at = rand(requested_at..Time.now)

        proposal.comments.create!(
          comment_text: Faker::Hacker.say_something_smart,
          created_at: commented_at,
          updated_at: commented_at,
          user_id: users.sample.id
        )
      end
    end
  end
end
