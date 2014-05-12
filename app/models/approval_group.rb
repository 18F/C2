class ApprovalGroup < ActiveRecord::Base
  belongs_to :cart
  has_one :requester
  has_and_belongs_to_many :users
  validates_uniqueness_of :name

end

