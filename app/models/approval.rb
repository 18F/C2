class Approval < ActiveRecord::Base
  include WorkflowModel
  has_paper_trail

  workflow do   # overwritten in child classes
    state :pending
    state :actionable
    state :approved
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
  scope :with_users, -> { includes :user }


  # Used by the state machine
  def on_approved_entry(new_state, event)
    self.update(approved_at: Time.now)
    self.proposal.partial_approve!
    Dispatcher.on_approval_approved(self)
  end
end
