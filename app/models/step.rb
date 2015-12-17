class Step < ActiveRecord::Base
  include WorkflowModel
  has_paper_trail class_name: "C2Version"

  workflow do # overwritten in child classes
    state :pending
    state :actionable
    state :approved
  end

  belongs_to :user
  belongs_to :proposal
  belongs_to :completer, class_name: "User"
  acts_as_list scope: :proposal
  belongs_to :parent, class_name: "Step"

  has_many :child_approvals, class_name: "Step", foreign_key: "parent_id", dependent: :destroy

  validates :proposal, presence: true
  validates :user_id, uniqueness: { scope: :proposal_id }, allow_blank: true

  scope :individual, -> { where(type: ["Steps::Approval", "Steps::Purchase"]).order("position ASC") }

  statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :non_pending, -> { where.not(status: "pending") }
  scope :outstanding, -> { where.not(status: "approved") }

  default_scope { order("position ASC") }

  def pre_order_tree_traversal
    [self] + child_approvals.flat_map(&:pre_order_tree_traversal)
  end

  def completed_by
    completer || user
  end

  protected

  def restart
    if parent
      parent.restart!
    end
  end

  def notify_parent_approved
    if parent
      parent.child_approved!(self)
    else
      proposal.approve!
    end
  end

  def children_approved?
    child_approvals.outstanding.empty?
  end
end
