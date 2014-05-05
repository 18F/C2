class Approver  < ActiveRecord::Base
  belongs_to :approval_group
  validates_presence_of :email_address
  validates_uniqueness_of :email_address, scope: :approval_group_id

  before_save :set_default_status
  has_many :approver_comment

  def set_default_status
    self.status = 'pending' if self.status.nil?
  end

end
