class Comment < ActiveRecord::Base
  include ObservableModel
  belongs_to :proposal
  belongs_to :user
  delegate :full_name, :email_address, :to => :user, :prefix => true

  validates :comment_text, presence: true
  validates :user, presence: true
  validates :proposal, presence: true

  # match .attributes
  def to_a
    [
      self.user_email_address,
      self.comment_text,
      self.updated_at,
      I18n.l(self.updated_at)
    ]
  end

  # match #to_a
  def self.attributes
    [
      'commenter',
      'cart comment',
      'created_at',
      'updated_at'
    ]
  end

  # All of the users who should be notified when a comment is created
  def listeners
    users_to_notify = []
    users_to_notify += self.proposal.currently_awaiting_approvers
    users_to_notify += self.proposal.approvals.approved.map(&:user)
    users_to_notify += self.proposal.observers
    users_to_notify << self.proposal.requester
    # Creator of comment doesn't need to be notified
    users_to_notify.delete(self.user)
    users_to_notify
  end
end
