class Step < ActiveRecord::Base
  include WorkflowModel
  has_paper_trail class_name: 'C2Version'

  workflow do # overwritten in child classes
    state :pending
    state :complete
  end

  belongs_to :proposal
  acts_as_list scope: :proposal
  validates :proposal, presence: true

  default_scope { order('position ASC') }

  scope :non_pending, -> { where.not(status: 'pending') }
end
