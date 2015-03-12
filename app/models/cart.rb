require 'csv'

class Cart < ActiveRecord::Base
  include PropMixin
  include ProposalDelegate

  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  has_one :approval_group
  has_many :user_roles, through: :approval_group
  has_many :api_tokens
  has_many :comments, as: :commentable
  has_many :properties, as: :hasproperties

  #TODO: validates_uniqueness_of :name

  ORIGINS = %w(navigator ncr)


  def rejections
    self.approver_approvals.rejected
  end

  def approver_approvals
    self.approvals.approvable
  end

  def approvers
    self.approval_users.merge(self.approver_approvals)
  end

  def awaiting_approvals
    self.approver_approvals.pending
  end

  def awaiting_approvers
    self.approval_users.merge(self.awaiting_approvals)
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
    self.approver_approvals.approved
  end

  def all_approvals_received?
    self.approver_approvals.where.not(status: 'approved').empty?
  end

  def requester
    self.approval_users.merge(Approval.requesting).first
  end

  def observers
    # TODO: Pull from approvals, not approval groups
    approval_group.user_roles.observers
  end

  def self.initialize_cart params
    cart = self.existing_or_new_cart params
    cart.initialize_approval_group params
    cart.setup_proposal(params)
    self.copy_existing_approvals_to(cart, name)

    cart
  end

  def self.existing_or_new_cart(params)
    name = params['cartName'].presence || params['cartNumber'].to_s

    pending_cart = Cart.pending.find_by(name: name)
    if pending_cart
      cart = reset_existing_cart(pending_cart)
    else
      #There is no existing cart or the existing cart is already approved
      cart = self.new(name: name, external_id: params['cartNumber'])
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

  def determine_flow(params)
    params['flow'].presence || self.approval_group.try(:flow) || 'parallel'
  end

  def setup_proposal(params)
    flow = self.determine_flow(params)
    self.create_proposal!(flow: flow, status: 'pending')
  end

  def import_initial_comments(comments)
    self.comments.create!(user_id: self.requester.id, comment_text: comments.strip)
  end

  # returns the Approval
  def add_approver(email)
    user = User.find_or_create_by(email_address: email)
    self.approvals.create!(user_id: user.id, role: 'approver')
  end

  def add_observer(email)
    user = User.find_or_create_by(email_address: email)
    self.approvals.create!(user_id: user.id, role: 'observer')
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

  def origin
    # In practice, carts should always have an origin. Account for test cases
    # and old data with this "or"
    self.getProp('origin') || ''
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
end
