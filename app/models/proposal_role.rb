class ProposalRole < ActiveRecord::Base
  belongs_to :user
  has_one :proposal
  has_one :role

  validates :user_id, presence: true
end
