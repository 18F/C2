require 'csv'

class Cart < ActiveRecord::Base
  include PropMixin
  has_many :cart_items
  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  has_one :approval_group
  has_one :api_token
  has_many :comments, as: :commentable

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

  def create_and_send_approvals
    approval_group.user_roles.each do | user_role |
      Approval.create!(user_id: user_role.user_id, cart_id: self.id, role: user_role.role)
    end

    approvals.where(role: "approver").each do | approval |
      ApiToken.create!(user_id: approval.user_id, cart_id: self.id, expires_at: Time.now + 7.days)
      CommunicartMailer.cart_notification_email(approval.user.email_address, self, approval).deliver
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
      csv << ["requester","cart comment","created_at"]
      date_sorted_comments = comments.sort { |a,b| a.updated_at <=> b.updated_at }
      date_sorted_comments.each do |item|
        csv << [requester.email_address, item.comment_text, item.updated_at, Cart.human_readable_time(item.updated_at, Cart.default_time_zone_offset)]
      end

      csv << ["commenter","approver comment","created_at"]
      approval_users.each do |user|
        user.comments.each do |comment|
          csv << [user.email_address, comment.comment_text, comment.updated_at]
        end
      end
    end
    return csv_string
  end

  def requester
    approvals.where(role: 'requester').first.user
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

  def self.initialize_cart_with_items(params)
    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']

    if pending_cart = Cart.find_by(name: name, status: 'pending')
      cart = reset_existing_cart(pending_cart)
    else
      cart = Cart.create!(name: name, status: 'pending', external_id: params['cartNumber'])
      copy_existing_approvals_to(cart, name)
    end

    if params['approvalGroup']
      cart.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
    else
      cart.approval_group = ApprovalGroup.create(name: "approval-group-#{params['cartNumber']}")
    end

    cart.save
    cart.add_cart_items(params['cartItems'])
    return cart
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
