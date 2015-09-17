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

  # we do not use rolify gem (e.g.) but declare relationship like any other.
  has_many :roles, class_name: 'UserRole'

  # TODO rename to _delegations, and add relations for the Users
  has_many :outgoing_delegates, class_name: 'ApprovalDelegate', foreign_key: 'assigner_id'
  has_many :incoming_delegates, class_name: 'ApprovalDelegate', foreign_key: 'assignee_id'

  # this is for user_roles specifically, not proposals or any other objects for which
  # this user might have roles.
  # rubocop:disable all
  def has_role?(name_or_role)
    if name_or_role.is_a?(Role)
      roles.any? { |user_role| user_role.role.name == name_or_role.name }
    else
      roles.any? { |user_role| user_role.role.name == name_or_role }
    end
  end
  # rubocop:enable all

  def add_role(name_or_role)
    return if has_role?(name_or_role)

    role = nil
    if name_or_role.is_a?(Role)
      role = name_or_role
    else
      role = Role.find_or_create_by(name: name_or_role)
    end
    user_role = UserRole.new(role: role)
    roles << user_role
  end

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
    self.has_role?('client_admin')
  end

  def admin?
    self.has_role?('admin')
  end

  def self.for_email(email)
    User.find_or_create_by(email_address: email.strip.downcase)
  end

  def self.from_oauth_hash(auth_hash)
    user_data = auth_hash.extra.raw_info.to_hash
    self.find_or_create_by(email_address: user_data['email'])
  end

  def role_on(proposal)
    RolePicker.new(self, proposal)
  end
end
