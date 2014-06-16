require 'csv'

class Cart < ActiveRecord::Base
  has_many :cart_items
  has_many :comments
  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  has_one :approval_group

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
      Approval.create!(user_id: user_role.user_id, cart_id: id, role: user_role.role)
      CommunicartMailer.cart_notification_email(user_role.user.email_address, self).deliver if user_role.role == "approver"
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
        user.approver_comments.each do |com|
          csv << [user.email_address, com.comment_text, com.updated_at]
        end
      end
    end
    return csv_string
  end

  def requester
    approval_group.user_roles.where(role: 'requester').first.user
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
    approval_group_name = params['approvalGroup']

    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']

    if existing_pending_cart =  Cart.find_by(name: name, status: 'pending')
      existing_pending_cart.approvals.map(&:destroy)
    end

    if existing_pending_cart.blank?

      cart = Cart.new(name: name, status: 'pending', external_id: params['cartNumber'])

      #Copy existing approvals and requester into a new set of approvals
      #REFACTOR
      if last_rejected_cart = Cart.where(name: name, status: 'rejected').last
        last_rejected_cart.approvals.each do | approval |
          new_approval = Approval.create!(user_id: approval.user_id, role: approval.role)
          cart.approvals << new_approval
          CommunicartMailer.cart_notification_email(new_approval.user.email_address, cart).deliver
        end
      end

    else

      cart = existing_pending_cart
      cart.cart_items.destroy_all
      cart.approval_group = nil

    end

    if !approval_group_name.blank?
      cart.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
    else
      cart.approval_group = ApprovalGroup.create(name: "approval-group-#{params['cartNumber']}")
    end
    cart.save

    params['cartItems'].each do |cart_item_params|
      ci = CartItem.create(
        :vendor => cart_item_params['vendor'],
        :description => cart_item_params['description'],
        :url => cart_item_params['url'],
        :notes => cart_item_params['notes'],
        :quantity => cart_item_params['qty'],
        :details => cart_item_params['details'],
        :part_number => cart_item_params['partNumber'],
        :price => cart_item_params['price'].gsub(/[\$\,]/,"").to_f,
        :cart_id => cart.id
      )
      if !cart_item_params['traits'].empty?
        cart_item_params['traits'].each do |trait|
          if trait[1].kind_of?(Array)
            trait[1].each do |individual|
              if !individual.blank?
                ci.cart_item_traits << CartItemTrait.new(:name => trait[0],:value => individual,:cart_item_id => ci.id)
              end
            end
          end
        end
      end
    end
    return cart
  end

end
