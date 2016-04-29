class FixStepUserCompleter < ActiveRecord::Migration
  class Proposal < ActiveRecord::Base
    has_many :steps
  end

  class Step < ActiveRecord::Base
    belongs_to :user
    belongs_to :completer, class_name: "User"
    belongs_to :proposal
  end

  class User < ActiveRecord::Base
    has_many :outgoing_delegations, class_name: "UserDelegate", foreign_key: "assigner_id"
    has_many :incoming_delegations, class_name: "UserDelegate", foreign_key: "assignee_id"
  end

  class UserDelegate < ActiveRecord::Base
    belongs_to :assignee, class_name: "User", foreign_key: "assignee_id"
    belongs_to :assigner, class_name: "User", foreign_key: "assigner_id"
  end

  def up
    steps_with_no_completer.each do |step|
      if user_is_delegate?(step)
        delegator = step.user.incoming_delegations.first.assigner
        next if proposal_has_step_user?(step.proposal, delegator)
        execute "UPDATE steps SET completer_id=#{step.user_id}, user_id=#{delegator.id} WHERE id=#{step.id}"
      end
    end
  end

  def down
  end

  def user_is_delegate?(step)
    step.user.incoming_delegations.count > 0
  end

  def steps_with_no_completer
    Step.where(completer_id: nil, status: :completed).where.not(user_id: nil)
  end

  def proposal_has_step_user?(proposal, user)
    proposal.steps.select { |step| step.user == user }.any?
  end
end
