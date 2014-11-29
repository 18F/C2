class CartExporter
  attr_reader :cart

  def initialize(cart_model)
    @cart = cart_model
  end

  def cart_items
    self.cart.cart_items
  end

  def items_csv
    CSV.generate do |csv|
      csv << CartItem.attributes
      self.cart_items.each do |item|
        csv << item.to_a
      end
    end
  end

  def comments
    self.cart.comments
  end

  def sorted_comments
    self.comments.order('updated_at ASC')
  end

  def comments_csv
    CSV.generate do |csv|
      csv << Comment.attributes
      self.sorted_comments.each do |comment|
        csv << comment.to_a
      end
    end
  end

  def approvals
    self.cart.approvals
  end

  def approvals_csv
    CSV.generate do |csv|
      csv << ["status","approver","created_at"]

      self.approvals.each do |approval|
        csv << [approval.status, approval.user.email_address,approval.updated_at]
      end
    end
  end
end
