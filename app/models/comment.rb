class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  has_many :approver_comments
  has_many :users, through: :approver_comments

  after_create :notify_approval_group

private
  def notify_approval_group
    case self.commentable_type
      when "CartItem"
        self.commentable.cart.approvals.each do | approval |
          CommunicartMailer.comment_added_email(self, approval.user.email_address).deliver
        end
      else
        # Do nothing
    end

  end

end
