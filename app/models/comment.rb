class Comment < ActiveRecord::Base
  include TimeHelper

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  after_create :notify_approval_group


  # match .attributes
  def to_a
    [
      self.user.email_address,
      self.comment_text,
      self.updated_at,
      human_readable_time(self.updated_at, default_time_zone_offset)
    ]
  end

  # match #to_a
  def self.attributes
    [
      'commenter',
      'cart comment',
      'created_at',
      'updated_at'
    ]
  end

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
