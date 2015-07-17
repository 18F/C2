class Approval < ActiveRecord::Base
  include WorkflowModel
  workflow do
    state :pending do
      event :make_actionable, transitions_to: :actionable
    end
    state :actionable do
      event :approve, transitions_to: :approved
    end
    state :approved

    # workflow doesn't touch active record
    # manually updating 'updated_at'
    # https://github.com/geekq/workflow/issues/96
    on_transition do |from, to, triggering_event, *event_args|
      self.touch
    end
  end

  belongs_to :proposal
  belongs_to :user
  has_one :api_token, -> { fresh }

  delegate :full_name, :email_address, :to => :user, :prefix => true

  acts_as_list scope: :proposal

  # TODO validates_uniqueness_of :user_id, scope: proposal_id

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end

  default_scope { order('position ASC') }


  # TODO we should probably store this value
  def approved_at
    if self.approved?
      self.updated_at
    else
      nil
    end
  end

  # Used by the state machine
  def on_approved_entry(new_state, event)
    self.proposal.partial_approve!
    Dispatcher.on_approval_approved(self)
  end
end
