class ProposalRole < ActiveRecord::Base
  belongs_to :user
  has_one :proposal
  has_one :role
end
