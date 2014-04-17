class Cart < ActiveRecord::Base
  has_many :cart_items
  has_one :approval_group

  def update_approval_status
    update_attributes(status: 'approved') if all_approvals_received?
  end

  def all_approvals_received?
    approval_group.approvers.where(status: 'approved').count == approval_group.approvers.count
  end

  def self.initialize_cart_with_items(params)
    approval_group_name = params['approvalGroup']
    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']
    cart = Cart.new(name: name, status: 'pending', external_id: params['cartNumber'])

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


    #TODO: accepts_nested_attributes_for
    params['cartItems'].each do |cart_item_params|
      CartItem.create(
        :vendor => cart_item_params['vendor'],
        :description => cart_item_params['description'],
        :url => cart_item_params['url'],
        :notes => cart_item_params['notes'],
        :quantity => cart_item_params['qty'],
        :details => cart_item_params['details'],
        :part_number => cart_item_params['partNumber'],
        :price => cart_item_params['price'],
        :cart_id => cart_item_params['features']
      )
    end
  end

end

# TODO: states: awaiting_approvals, approved, rejected
