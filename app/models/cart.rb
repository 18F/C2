require 'csv'

class Cart < ActiveRecord::Base
  include PropMixin
  has_many :cart_items
  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  has_one :approval_group
  has_one :api_token
  has_many :comments, as: :commentable
  #TODO: after_save default status
  #TODO: validates_uniqueness_of :name

  APPROVAL_ATTRIBUTES_MAP = {
    approve: 'approved',
    reject: 'rejected'
  }
  has_many :properties, as: :hasproperties

  def self.human_readable_time(t1,offset)
    return t1.utc.getlocal(offset).asctime
  end

  def self.default_time_zone_offset
    return "-04:00"
  end

  def update_approval_status
    return update_attributes(status: 'rejected') if has_rejection?
    return update_attributes(status: 'approved') if all_approvals_received?
  end

  def has_rejection?
    approvals.map(&:status).include?('rejected')
  end

  def all_approvals_received?
    approver_count = approvals.where(role: 'approver').count
    approvals.where(role: 'approver').where(status: 'approved').count == approver_count
  end

  def deliver_approval_emails
    approvals.where(role: "approver").each do |approval|
      ApiToken.create!(user_id: approval.user_id, cart_id: self.id, expires_at: Time.now + 7.days)
      CommunicartMailer.cart_notification_email(approval.user.email_address, self, approval).deliver
    end
    approvals.where(role: 'observer').each do |observer|
      CommunicartMailer.cart_observer_email(observer.user.email_address, self).deliver
    end
  end

  def create_items_csv
    csv_string = CSV.generate do |csv|
    csv << ["description","details","vendor","url","notes","part_number","green","features","socio","quantity","unit price","price for quantity"]
    cart_items.each do |item|
        csv << [item.description,item.details,item.vendor,item.url,item.notes,item.part_number,item.green?,item.features,item.socio,item.quantity,item.price,item.quantity*item.price]
        end
    end
    return csv_string
  end

  def create_comments_csv
    csv_string = CSV.generate do |csv|
      csv << ["commenter","cart comment","created_at"]
      date_sorted_comments = comments.sort { |a,b| a.updated_at <=> b.updated_at }
      date_sorted_comments.each do |item|
        user = User.find(item.user_id)
        csv << [user.email_address, item.comment_text, item.updated_at, Cart.human_readable_time(item.updated_at, Cart.default_time_zone_offset)]
      end
    end
    return csv_string
  end

  def requester
    approvals.where(role: 'requester').first.user if approvals.any? { |a| a.role == 'requester' }
  end

  def observers
    approval_group.user_roles.where(role: 'observer') #TODO: Pull from approvals, not approval groups
  end

  def create_approvals_csv
    csv_string = CSV.generate do |csv|
    csv << ["status","approver","created_at"]

    approvals.each do |approval|
        csv << [approval.status, approval.user.email_address,approval.updated_at]
        end
    end
    return csv_string
  end

  def self.initialize_cart_with_items params
    begin
      cart = self.existing_or_new_cart params
      cart.initialize_approval_group params
      return cart
    rescue Exception => e
      raise
    end
  end

  def self.existing_or_new_cart(params)
    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']

    if pending_cart = Cart.find_by(name: name, status: 'pending')
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
      self.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
    else
      # TODO: Create users
      self.approval_group = ApprovalGroup.create(name: "approval-group-#{params['cartNumber']}")
    end
  end

  def self.initialize_informal_cart(params)
    cart = Cart.create!(name: 'sampleNameThatIsNotReally', status: 'pending')
    cart.save
    ci = CartItem.create(
                         :cart_id => cart.id
                         )

    return cart
  end

  def add_initial_comments(comments)
    self.comments << Comment.create!(user_id: self.requester.id, comment_text: comments.strip)
  end


  def process_approvals_without_approval_group(params)
    raise 'approvalGroup exists' if params['approvalGroup'].present?

    params['toAddress'].each do |email|
      user = User.find_or_create_by(email_address: email)
      Approval.create!(cart_id: self.id, user_id: user.id, role: 'approver')
    end

    requester = User.find_or_create_by(email_address: params['fromAddress'])
    Approval.create!(cart_id: self.id, user_id: requester.id, role: 'requester')
  end

  def process_approvals_from_approval_group
    approval_group.user_roles.each do | user_role |
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
      previous_cart.approvals.each do | approval |
        new_cart.approvals << Approval.create!(user_id: approval.user_id, role: approval.role)
        CommunicartMailer.cart_notification_email(approval.user.email_address, new_cart).deliver
      end
    end
  end

  def add_cart_items(cart_items_params)
    cart_items_params.each do |params|
      ci = CartItem.create(
        :vendor => params['vendor'],
        :description => params['description'],
        :url => params['url'],
        :notes => params['notes'],
        :quantity => params['qty'],
        :details => params['details'],
        :part_number => params['partNumber'],
        :price => params['price'].gsub(/[\$\,]/,"").to_f,
        :cart_id => id
      )

      if params['properties']
        params['properties'].each do |item_property_values|
          item_property_values.each do |key,val|
            ci.setProp(key,val)
          end
        end
      end

      if params['traits']
        params['traits'].each do |trait|
          if trait[1].kind_of?(Array)
            trait[1].each do |individual|
              if !individual.blank?
                ci.cart_item_traits << CartItemTrait.new( :name => trait[0],
                                                          :value => individual,
                                                          :cart_item_id => ci.id
                                                        )
              end
            end
          end
        end
      end
    end
  end

end
