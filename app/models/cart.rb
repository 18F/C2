require 'csv'

class Cart < ActiveRecord::Base
  include PropMixin
  include TimeHelper
  has_many :cart_items
  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  has_one :approval_group
  has_one :api_token
  has_many :comments, as: :commentable
  has_many :properties, as: :hasproperties

  #TODO: after_save default status
  #TODO: validates_uniqueness_of :name


  def update_approval_status
    if self.has_rejection?
      self.update_attributes(status: 'rejected')
    elsif self.all_approvals_received?
      self.update_attributes(status: 'approved')
    end
  end

  def rejections
    self.approvals.where(status: 'rejected')
  end

  def has_rejection?
    self.rejections.any?
  end

  def approver_approvals
    self.approvals.where(role: 'approver')
  end

  def all_approvals_received?
    self.approver_approvals.where('status != ?', 'approved').empty?
  end

  def create_items_csv
    csv_string = CSV.generate do |csv|
      csv << ["description","details","vendor","url","notes","part_number","green","features","socio","quantity","unit price","price for quantity"]
      cart_items.each do |item|
        csv << [item.description,
                item.details,
                item.vendor,
                item.url,
                item.notes,
                item.part_number,
                item.green?,
                item.features,
                item.socio,
                item.quantity,
                item.price,
                item.quantity * item.price
               ]
      end
    end

    csv_string
  end

  def create_comments_csv
    csv_string = CSV.generate do |csv|
      csv << ["commenter","cart comment","created_at"]
      date_sorted_comments = comments.sort { |a,b| a.updated_at <=> b.updated_at }
      date_sorted_comments.each do |item|
        user = User.find(item.user_id)
        csv << [user.email_address, item.comment_text, item.updated_at, human_readable_time(item.updated_at, default_time_zone_offset)]
      end
    end

    csv_string
  end

  def requester
    approvals.where(role: 'requester').first.try(:user)
  end

  def observers
    # TODO: Pull from approvals, not approval groups
    approval_group.user_roles.where(role: 'observer')
  end

  def create_approvals_csv
    csv_string = CSV.generate do |csv|
      csv << ["status","approver","created_at"]

      approvals.each do |approval|
        csv << [approval.status, approval.user.email_address,approval.updated_at]
      end
    end

    csv_string
  end

  def self.initialize_cart_with_items params
    cart = self.existing_or_new_cart params
    cart.initialize_approval_group params
    cart
  end

  def self.existing_or_new_cart(params)
    name = params['cartName'].presence || params['cartNumber']

    pending_cart = Cart.find_by(name: name, status: 'pending')
    if pending_cart
      cart = reset_existing_cart(pending_cart)
    else
      #There is no existing cart or the existing cart is already approved
      cart = Cart.create!(name: name, status: 'pending', external_id: params['cartNumber'])
      copy_existing_approvals_to(cart, name)
    end
    return cart
  end

  def initialize_approval_group(params)
    if params['approvalGroup']
      #TODO: Handle approvalGroup non-existent approval group
      self.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
    end
  end

  def import_initial_comments(comments)
    self.comments << Comment.create!(user_id: self.requester.id, comment_text: comments.strip)
  end

  def process_approvals_without_approval_group(params)
    if params['approvalGroup'].present?
      raise 'approvalGroup exists'
    end
    approver_emails = params['toAddress'].select(&:present?)

    approver_emails.each do |email|
      user = User.find_or_create_by(email_address: email)
      Approval.create!(cart_id: self.id, user_id: user.id, role: 'approver')
    end

    if params['fromAddress']
      requester = User.find_or_create_by(email_address: params['fromAddress'])
      Approval.create!(cart_id: self.id, user_id: requester.id, role: 'requester')
    end
  end

  def process_approvals_from_approval_group
    approval_group.user_roles.each do |user_role|
      Approval.create!(user_id: user_role.user_id, cart_id: self.id, role: user_role.role)
    end
  end

  def self.reset_existing_cart(cart)
    cart.approvals.map(&:destroy)
    cart.cart_items.destroy_all
    cart.approval_group = nil
    return cart
  end

  def self.copy_existing_approvals_to(new_cart, cart_name)
    previous_cart = Cart.where(name: cart_name).last
    if previous_cart && previous_cart.status == 'rejected'
      previous_cart.approvals.each do |approval|
        new_cart.approvals << Approval.create!(user_id: approval.user_id, role: approval.role)
        CommunicartMailer.cart_notification_email(approval.user.email_address, new_cart, approval).deliver
      end
    end
  end

  def import_cart_properties(cart_properties_params)
    unless cart_properties_params.blank?
      cart_properties_params.each do |key, val|
        self.setProp(key, val)
      end
    end
  end

  def import_cart_items(cart_items_params)
    unless cart_items_params.blank?
      cart_items_params.each do |params|
        params = params.dup
        params.delete_if {|k,v| v.blank? }

        ci = CartItem.create(
          :vendor => params.fetch(:vendor, nil),
          :description => params.fetch(:description, nil),
          :url => params.fetch(:url, nil),
          :notes => params.fetch(:notes, nil),
          :quantity => params.fetch(:qty , 0),
          :details => params.fetch(:details, nil),
          :part_number => params.fetch(:partNumber , nil),
          :price => params.fetch(:price, nil).gsub(/[\$\,]/,"").to_f,
          :cart_id => id
        )

        if params['traits']
          params['traits'].each do |trait|
            if trait[1].kind_of?(Array)
              trait[1].each do |individual|
                if individual.present?
                  ci.cart_item_traits << CartItemTrait.new( :name => trait[0],
                                                            :value => individual,
                                                            :cart_item_id => ci.id
                                                          )
                end
              end
            end
          end
        end

        unless params['properties'].blank?
          params['properties'].each do |key,val|
            ci.setProp(key, val)
          end
        end

      end
    end
  end
end
