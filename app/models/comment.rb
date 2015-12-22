class Comment < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'

  belongs_to :proposal
  belongs_to :user
  delegate :full_name, :email_address, :to => :user, :prefix => true

  validates :comment_text, presence: true
  validates :user, presence: true
  validates :proposal, presence: true

  scope :normal_comments, ->{ where(update_comment: nil) } # we probably want `.where.not(update_comment: true)`, but that query isn't working as of 5bb8b4d385
  scope :update_comments, ->{ where(update_comment: true) }


  after_create :add_user_as_observer

  # match .attributes
  def to_a
    [
      user_email_address,
      comment_text,
      updated_at,
      I18n.l(updated_at)
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

  def add_user_as_observer
    proposal.add_observer(user.email_address)
  end

  # All of the users who should be notified when a comment is created
  # This is basically Proposal.users _minus_ future approvers
  def listeners
    users_to_notify = Set.new
    users_to_notify += proposal.currently_awaiting_approvers
    users_to_notify += proposal.individual_steps.approved.map(&:user)
    users_to_notify += proposal.observers
    users_to_notify << proposal.requester
    # Creator of comment doesn't need to be notified
    users_to_notify.delete(user)
    users_to_notify
  end
end
