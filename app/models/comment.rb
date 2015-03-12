class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  delegate :full_name, :email_address, :to => :user, :prefix => true

  after_create :notify_approval_group


  # match .attributes
  def to_a
    [
      self.user_email_address,
      self.comment_text,
      self.updated_at,
      I18n.l(self.updated_at)
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
    # TODO notify for Carts, though probably not if they are already getting an approval/rejection notification
  end
end
