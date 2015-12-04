class User < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'

  validates :client_slug, inclusion: {
    in: ->(_) { Proposal.client_slugs },
    message: "'%{value}' is not in Proposal.client_slugs #{Proposal.client_slugs.inspect}",
    allow_blank: true
  }
  validates :email_address, presence: true, uniqueness: true
  validates_email_format_of :email_address

  has_many :steps, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :observations, dependent: :destroy

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :proposals, foreign_key: "requester_id", dependent: :destroy

  has_many :outgoing_delegations, class_name: 'ApprovalDelegate', foreign_key: 'assigner_id'
  has_many :outgoing_delegates, through: :outgoing_delegations, source: :assignee

  has_many :incoming_delegations, class_name: 'ApprovalDelegate', foreign_key: 'assignee_id'
  has_many :incoming_delegates, through: :incoming_delegations, source: :assigner

  has_many :completed_steps, class_name: "Step", foreign_key: "completer"

  def self.active
    where(active: true)
  end

  def self.sql_for_role_slug(role_name, slug)
    self.with_role(role_name).select(:id).where(client_slug: slug).to_sql
  end

  def self.with_role(role_name)
    User.joins(:roles).where(roles: { name: role_name })
  end

  def self.for_email(email)
    User.find_or_create_by(email_address: email.strip.downcase)
  end

  def self.for_email_with_slug(email, client_slug)
    user = for_email(email)

    unless user.client_slug
      user.client_slug = client_slug
    end

    user
  end

  def self.from_oauth_hash(auth_hash)
    user_data = auth_hash.extra.raw_info.to_hash
    user = self.for_email(user_data["email"])
    user.update_names_if_present(user_data)
    user
  end

  def add_role(role_name)
    role = Role.find_or_create_by!(name: role_name)
    user_roles.find_or_create_by!(role: role)
  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    else
      email_address
    end
  end

  def display_name
    if full_name == email_address
      email_address
    else
      "#{full_name} <#{email_address}>"
    end
  end

  def last_requested_proposal
    proposals.order("created_at DESC").first
  end

  def add_delegate(other)
    outgoing_delegations.create!(assignee: other)
  end

  def delegates_to?(other)
    outgoing_delegations.exists?(assignee: other)
  end

  def client_admin?
    roles.exists?(name: "client_admin")
  end

  def admin?
    roles.exists?(name: "admin")
  end

  def not_admin?
    !admin?
  end

  def deactivated?
    !active?
  end

  def update_names_if_present(user_data)
    %w(first_name last_name).each do |field|
      attr = field.to_sym
      if user_data[field].present? && self.send(attr).blank?
        update_attributes(attr => user_data[field])
      end
    end
  end

  def role_on(proposal)
    RolePicker.new(self, proposal)
  end

  def requires_profile_attention?
    first_name.blank? || last_name.blank?
  end
end
