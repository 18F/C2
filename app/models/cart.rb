require 'csv'

class Cart < ActiveRecord::Base
  include PropMixin
  include ProposalDelegate

  has_one :approval_group
  has_many :user_roles, through: :approval_group
  has_many :api_tokens, through: :approvals
  has_many :comments, as: :commentable
  has_many :properties, as: :hasproperties

  #TODO: validates_uniqueness_of :name

  ORIGINS = %w(navigator ncr gsa18f)


  def rejections
    self.approvals.rejected
  end

  def approved_approvals
    self.approvals.approved
  end

  def all_approvals_received?
    self.approvals.where.not(status: 'approved').empty?
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
    self.comments.create!(user_id: self.proposal.requester_id, comment_text: comments.strip)
  end

  def create_approvals(emails)
    emails.each do |email|
      self.add_approver(email)
    end
  end

  def process_approvals_without_approval_group(params)
    if params['approvalGroup'].present?
      raise ApprovalGroupError.new('Approval Group already exists')
    end
    approver_emails = params['toAddress'].select(&:present?)
    self.create_approvals(approver_emails)

    requester_email = params['fromAddress']
    if requester_email
      self.add_requester(requester_email)
    end
  end

  def create_approval_from_user_role(user_role)
    case user_role.role
    when 'approver'
      Approval.create!(
        position: user_role.position,
        proposal_id: self.proposal_id,
        user_id: user_role.user_id
      )
    when 'observer'
      Observation.create!(
        proposal_id: self.proposal_id,
        user_id: user_role.user_id
      )
    when 'requester'
      self.set_requester(user_role.user)
    else
      raise "Unknown role #{user_role.inspect}"
    end
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

  def gsa_advantage?
    self.client == 'gsa_advantage'
  end

  # Some fields aren't meant for the clients' eyes
  EXCLUDE_FIELDS_FROM_DISPLAY = ['origin', 'contractingVehicle', 'location', 'configType']
  # The following methods are an interface which should be matched by client
  # models
  def fields_for_display
    self.properties_with_names.reject{ |key,value,label|
      EXCLUDE_FIELDS_FROM_DISPLAY.include? key}.map{ |key,value,label|
      [label, value] }
  end

  def client
    self.getProp('origin') || 'gsa_advantage'
  end

  # @todo - the method name (e.g. :external_id) should live on a "client"
  # model
  def public_identifier
    self.external_id
  end

  def total_price
    if self.client == 'gsa18f'
      self.getProp('cost_per_unit').to_f * self.getProp('quantity').to_f
    else
      0.0
    end
  end

  # may be replaced with paper-trail or similar at some point
  def version
    self.updated_at.to_i
  end
end
