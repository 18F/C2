class User < ActiveRecord::Base
  has_paper_trail class_name: "C2Version"

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

  has_many :outgoing_delegations, class_name: "UserDelegate", foreign_key: "assigner_id"
  has_many :outgoing_delegates, through: :outgoing_delegations, source: :assignee

  has_many :incoming_delegations, class_name: "UserDelegate", foreign_key: "assignee_id"
  has_many :incoming_delegates, through: :incoming_delegations, source: :assigner

  has_many :completed_steps, class_name: "Step", foreign_key: "completer"

  has_many :reports
  has_many :scheduled_reports

  has_many :oauth_applications, class_name: "Doorkeeper::Application", as: :owner

  has_many :visits
  has_many :ahoy_events, through: :visits

  DEFAULT_TIMEZONE = "Eastern Time (US & Canada)".freeze

  def self.active
    where(active: true)
  end

  def self.with_slug(slug)
    User.where(client_slug: slug)
  end

  def self.sql_for_role_slug(role_name, slug)
    with_role(role_name).select(:id).where(client_slug: slug).to_sql
  end

  def self.with_role(role_name)
    User.joins(:roles).where(roles: { name: role_name })
  end

  def self.for_email(email)
    raise(EmailRequired, "email missing") unless email.present?
    User.find_or_create_by(email_address: email.strip.downcase)
  end

  def self.for_email_with_slug(email, client_slug)
    user = for_email(email)
    user.client_slug = client_slug unless user.client_slug
    user
  end

  def self.from_oauth_hash(auth_hash)
    user_data = auth_hash.extra.raw_info.to_hash
    unless user_data["email"].present?
      raise EmailRequired, "no email in oauth hash"
    end
    user = for_email(user_data["email"])
    user.update_names_if_present(user_data)
    user
  end

  def client_model
    Proposal.client_model_for(self)
  end

  def client_model_slug
    client_model.to_s.underscore.tr("/", "_")
  end

  def add_role(role_name)
    new_role = Role.find_or_create_by!(name: role_name)
    roles << new_role unless roles.include?(new_role)
  end

  def remove_role(role_name)
    role = Role.find_by(name: role_name)
    user_roles.find_by(role: role)&.destroy!
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

  def to_s
    display_name
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

  def any_admin?
    admin? || client_admin? || gateway_admin?
  end

  def client_admin?
    role? ROLE_CLIENT_ADMIN
  end

  def gateway_admin?
    role? ROLE_GATEWAY_ADMIN
  end

  def admin?
    role? ROLE_ADMIN
  end

  def should_see_beta?(feature)
    can_see_beta?(feature) && active_beta_user?
  end

  # Does the user have permission to see this beta feature?
  def can_see_beta?(feature)
    fail "No feature given" unless feature
    feature_enabled = ENV[feature] == "true"
    in_beta_program? && feature_enabled
  end

  def in_beta_program?
    role? ROLE_BETA_USER
  end

  def active_beta_user?
    role?(ROLE_BETA_ACTIVE) && in_beta_program?
  end

  def toggle_active_beta
    if active_beta_user?
      remove_role(ROLE_BETA_ACTIVE)
    else
      add_role(ROLE_BETA_ACTIVE)
    end
  end

  def check_beta_state
    if AppConfigCredentials.redesign_default_view == "true" && !in_beta_program?
      add_role(ROLE_BETA_USER)
      add_role(ROLE_BETA_ACTIVE)
    end
  end

  def not_admin?
    !admin?
  end

  def role?(role_name)
    Rails.logger.info("Authorization check: #{email_address}, #{role_name}")
    role_names.include? role_name
  end

  def role_names
    @role_names ||= roles.pluck(:name)
  end

  def deactivated?
    !active?
  end

  def update_names_if_present(user_data)
    %w(first_name last_name).each do |field|
      attr = field.to_sym
      if user_data[field].present? && send(attr).blank?
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

  def all_reports
    Report.for_user(self)
  end
end
