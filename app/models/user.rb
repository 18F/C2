class User < ActiveRecord::Base
  has_paper_trail

  validates :client_slug, inclusion: {
    in: ->(_) { Proposal.client_slugs },
    allow_blank: true
  }
  validates :email_address, presence: true, uniqueness: true
  validates_email_format_of :email_address

  has_many :approvals
  has_many :observations
  has_many :comments

  # TODO rename to _delegations, and add relations for the Users
  has_many :outgoing_delegates, class_name: 'ApprovalDelegate', foreign_key: 'assigner_id'
  has_many :incoming_delegates, class_name: 'ApprovalDelegate', foreign_key: 'assignee_id'

  def full_name
    if first_name && last_name
      "#{first_name} #{last_name}"
    else
      email_address
    end
  end

  def requested_proposals
    Proposal.where(requester_id: self.id)
  end

  def last_requested_proposal
    self.requested_proposals.order('created_at DESC').first
  end

  def add_delegate(other)
    self.outgoing_delegates.create!(assignee: other)
  end

  def delegates_to?(other)
    self.outgoing_delegates.exists?(assignee_id: other.id)
  end

  def client_admin?
    self.class.client_admin_emails.include?(self.email_address)
  end

  def admin?
    self.class.admin_emails.include?(self.email_address)
  end

  def self.for_email(email)
    User.find_or_create_by(email_address: email.strip.downcase)
  end

  def self.from_oauth_hash(auth_hash)
    user_data = auth_hash.extra.raw_info.to_hash
    self.find_or_create_by(email_address: user_data['email'])
  end

  def self.client_admin_emails
    ENV['CLIENT_ADMIN_EMAILS'].to_s.split(',')
  end

  def self.admin_emails
    ENV['ADMIN_EMAILS'].to_s.split(',')
  end

  def role_on(proposal)
    Role.new(self,proposal)
  end
end
