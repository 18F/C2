class Comment < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user
  delegate :full_name, :email_address, :to => :user, :prefix => true

  validates :comment_text, presence: true
  validates :user, presence: true
  validates :proposal, presence: true

  scope :update_comments, ->{ where(update_comment: true) }

  after_create ->{ Dispatcher.on_comment_created(self) }

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
  # TODO use i18n
  def self.attributes
    [
      'commenter',
      'comment text',
      'created_at',
      'updated_at'
    ]
  end

  # All of the users who should be notified when a comment is created
  # This is basically Proposal.users _minus_ future approvers
  def listeners
    users_to_notify = Set.new
    users_to_notify += self.proposal.currently_awaiting_approvers
    users_to_notify += self.proposal.user_approvals.approved.map(&:user)
    users_to_notify += self.proposal.observers
    users_to_notify << self.proposal.requester
    # Creator of comment doesn't need to be notified
    users_to_notify.delete(self.user)
    users_to_notify
  end
end
