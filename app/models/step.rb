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
  acts_as_list scope: :proposal
  belongs_to :parent, class_name: "Step"

  has_many :child_approvals, class_name: "Step", foreign_key: "parent_id", dependent: :destroy

  validates :proposal, presence: true
  validates :user_id, uniqueness: { scope: :proposal_id }, allow_blank: true

  # @TODO: Auto-generate list of subclasses
  scope :individual, -> { where(type: ["Steps::Approval", "Steps::Purchase"]).order("position ASC") }

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :non_pending, -> { where.not(status: "pending") }
  scope :outstanding, -> { where.not(status: "approved") }

  default_scope { order("position ASC") }

  # TODO make a protected method
  def notify_parent_approved
    if self.parent
      self.parent.child_approved!(self)
    else
      self.proposal.approve!
    end
  end

  def children_approved?
    self.child_approvals.outstanding.empty?
  end

  def pre_order_tree_traversal
    [self] + self.child_approvals.flat_map(&:pre_order_tree_traversal)
  end

  protected

  def restart
    if self.parent
      self.parent.restart!
    end
  end
end
