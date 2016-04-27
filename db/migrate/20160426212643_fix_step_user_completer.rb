class FixStepUserCompleter < ActiveRecord::Migration
  class Step < ActiveRecord::Base
    belongs_to :user
    belongs_to :completer, class_name: "User"
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
        step.update_attributes!(completer: step.user, user: delegator)
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
end
