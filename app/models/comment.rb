class Comment < ActiveRecord::Base
  include ObservableModel
  belongs_to :proposal
  belongs_to :user
  delegate :full_name, :email_address, :to => :user, :prefix => true

  validates :comment_text, presence: true

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
end
