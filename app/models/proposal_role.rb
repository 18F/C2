class ProposalRole < ActiveRecord::Base
  has_paper_trail class_name: "C2Version"

  belongs_to :user
  belongs_to :proposal, touch: true
  has_one :role

  validates :user, presence: true
end
