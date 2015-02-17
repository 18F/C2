require 'csv'

class Cart < ActiveRecord::Base
  include PropMixin
  include WorkflowHelper::ThreeStateWorkflow

  workflow_column :status

  has_many :cart_items
  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  has_one :approval_group
  has_many :user_roles, through: :approval_group
  has_one :api_token
  has_many :comments, as: :commentable
  has_many :properties, as: :hasproperties

  #TODO: validates_uniqueness_of :name
  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}

  scope :approved, -> { where(status: 'approved') }
  scope :open, -> { where(status: 'pending') }
  scope :closed, -> { where(:status => ['approved', 'rejected']) }

  ORIGINS = %w(navigator ncr)

  def rejections
    self.approvals.where(status: 'rejected')
  end

  def approver_approvals
    self.approvals.where(role: 'approver')
  end

  def approvers
    # TODO do through SQL
    self.approver_approvals.map(&:user)
  end

  def awaiting_approvals
    self.approver_approvals.pending
  end

  def awaiting_approvers
    # TODO do through SQL
    self.awaiting_approvals.map(&:user)
  end

  def ordered_approvals
    self.approver_approvals.order('position ASC')
  end

  def ordered_awaiting_approvals
    self.ordered_approvals.pending
  end

  # users with outstanding cart_notification_emails
  def currently_awaiting_approvers
    if self.parallel?
      # TODO do through SQL
      self.ordered_awaiting_approvals.map(&:user)
    else # linear. Assumes the cart is open
      approval = self.ordered_awaiting_approvals.first
      [approval.user]
    end
  end

  def approved_approvals
    self.approver_approvals.where(status: 'approved')
  end

  def all_approvals_received?
    self.approver_approvals.where('status != ?', 'approved').empty?
  end

  def requester
    approvals.where(role: 'requester').first.try(:user)
  end

  def observers
    # TODO: Pull from approvals, not approval groups
    approval_group.user_roles.where(role: 'observer')
  end

  def self.initialize_cart_with_items params
    cart = self.existing_or_new_cart params
    cart.initialize_approval_group params
    cart.initialize_flow(params)
    self.copy_existing_approvals_to(cart, name)

    cart
  end

  def self.existing_or_new_cart(params)
    name = params['cartName'].presence || params['cartNumber'].to_s

    pending_cart = Cart.find_by(name: name, status: 'pending')
    if pending_cart
      cart = reset_existing_cart(pending_cart)
    else
      #There is no existing cart or the existing cart is already approved
      cart = Cart.new(name: name, status: 'pending', external_id: params['cartNumber'])
    end

    cart
  end

  def initialize_approval_group(params)
    if params['approvalGroup']
      self.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
      if self.approval_group.nil?
        raise ApprovalGroupError.new('Approval Group Not Found')
      end
    end
  end

  def initialize_flow(params)
    self.flow = params['flow'].presence || self.flow || self.approval_group.try(:flow) || 'parallel'
  end

  def import_initial_comments(comments)
    self.comments.create!(user_id: self.requester.id, comment_text: comments.strip)
  end

  def add_approver(email)
    user = User.find_or_create_by(email_address: email)
    self.approvals.create!(user_id: user.id, role: 'approver')
  end

  def create_approver_approvals(emails)
    emails.each do |email|
      self.add_approver(email)
    end
  end

  def set_requester(user)
    self.approvals.create!(user_id: user.id, role: 'requester')
  end

  def create_requester(email)
    user = User.find_or_create_by(email_address: email)
    self.set_requester(user)
  end

  def process_approvals_without_approval_group(params)
    if params['approvalGroup'].present?
      raise ApprovalGroupError.new('Approval Group already exists')
    end
    approver_emails = params['toAddress'].select(&:present?)
    self.create_approver_approvals(approver_emails)

    requester_email = params['fromAddress']
    if requester_email
      self.create_requester(requester_email)
    end
  end

  def create_approval_from_user_role(user_role)
    approval = Approval.new_from_user_role(user_role)
    approval.cart = self
    approval.save!
    approval
  end

  def process_approvals_from_approval_group
    approval_group.user_roles.each do |user_role|
      self.create_approval_from_user_role(user_role)
    end
  end

  def copy_existing_approval(approval)
    new_approval = self.approvals.create!(user_id: approval.user_id, role: approval.role)
    Dispatcher.new.email_approver(new_approval)
  end

  def self.reset_existing_cart(cart)
    cart.approvals.map(&:destroy)
    cart.cart_items.destroy_all
    cart.approval_group = nil

    cart
  end

  def self.copy_existing_approvals_to(new_cart, cart_name)
    previous_cart = Cart.where(name: cart_name).last
    if previous_cart && previous_cart.rejected?
      previous_cart.approvals.each do |approval|
        new_cart.copy_existing_approval(approval)
      end
    end
  end

  def import_cart_item(params)
    params = params.dup
    params.delete_if {|k,v| v.blank? }

    ci = CartItem.from_params(params)
    ci.cart = self
    ci.save!
  end

  def import_cart_items(cart_items_params)
    cart_items_params.each do |params|
      self.import_cart_item(params)
    end
  end

  def origin
    self.getProp('origin')
  end

  def ncr?
    self.origin == 'ncr'
  end

  def gsa_advantage?
    # TODO set the origin
    self.origin.blank?
  end

  # TODO use this when retrieving
  def public_identifier_method
    if self.ncr?
      :id
    else
      :external_id
    end
  end

  def public_identifier
    self.send(self.public_identifier_method)
  end

  def parallel?
    self.flow == 'parallel'
  end

  def linear?
    self.flow == 'linear'
  end

  # Used by the state machine
  def on_pending_entry(new_state, event)
    if self.all_approvals_received?
      self.approve!
    end
  end
end
