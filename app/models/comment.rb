class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  after_create :notify_approval_group

private
  def notify_approval_group
    case self.commentable_type
      when "CartItem"
        self.commentable.cart.approvals.each do | approval |
          email = approval.user.email_address
          CommunicartMailer.comment_added_email(self, email).deliver
        end
      else
        # Do nothing
    end

  end

end
