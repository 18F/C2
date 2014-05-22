require 'csv'

class Cart < ActiveRecord::Base
  has_many :cart_items
  has_many :comments
  has_one :approval_group

  def update_approval_status
    update_attributes(status: 'approved') if all_approvals_received?
  end

  def all_approvals_received?
    approval_group.approvers.where(status: 'approved').count == approval_group.approvers.count
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

# Note: I think the model for this is a little wrong.  We need comments on the
# the cart, but in fact, we are operating on comments on approvals, which we don't model at present.
  def create_comments_csv
    csv_string = CSV.generate do |csv|
      csv << ["requester","cart comment","created_at"]
      date_sorted_comments = comments.sort { |a,b| a.updated_at <=> b.updated_at }
      date_sorted_comments.each do |item|
        csv << [approval_group.requester.email_address,item.comment_text,item.updated_at]
      end

      csv << ["commenter","approver comment","created_at"]
      approval_group.approvers.each do |app|
        app.approver_comments.each do |com|
          csv << [app.email_address,com.comment_text,com.updated_at]
        end
      end
    end
    return csv_string
  end

  def create_approvals_csv
    csv_string = CSV.generate do |csv|
    csv << ["status","approver","created_at"]
    approval_group.approvers.each do |app|
        csv << [app.status,app.email_address,app.updated_at]
        end
    end
    return csv_string
  end

  def self.initialize_cart_with_items(params)
    approval_group_name = params['approvalGroup']

    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']

    existing_cart =  Cart.find_by(name: name)
    if existing_cart.blank?
      cart = Cart.new(name: name, status: 'pending', external_id: params['cartNumber'])
    else
      cart = existing_cart
      cart.cart_items.destroy_all
      cart.approval_group = nil
    end

    if !approval_group_name.blank?
      cart.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
    else
      cart.approval_group = ApprovalGroup.create(
                                                 name: "approval-group-#{params['cartNumber']}",
                                                 approvers_attributes: [
                                                                        { email_address: params['fromAddress'] }
                                                                       ]
                                                 )
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

# TODO: states: awaiting_approvals, approved, rejected
