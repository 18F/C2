class Step < ActiveRecord::Base
  include WorkflowModel
  has_paper_trail class_name: "C2Version"

  workflow do # overwritten in child classes
    state :pending
    state :actionable
    state :completed
  end

  has_one :api_token, -> { fresh }, foreign_key: "step_id"
  belongs_to :user
  belongs_to :proposal, touch: true
  belongs_to :completer, class_name: "User"
  acts_as_list scope: :proposal
  belongs_to :parent, class_name: "Step"

  has_many :child_steps, class_name: "Step", foreign_key: "parent_id", dependent: :destroy

  validates :proposal, presence: true
  validates :user_id, uniqueness: { scope: :proposal_id }, allow_blank: true
  scope :individual, -> { where.not(type: ["Steps::Serial", "Steps::Parallel"]).order("position ASC") }
  scope :with_users, -> { includes :user }

  statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :non_pending, -> { where.not(status: "pending") }
  scope :outstanding, -> { where.not(status: "completed") }

  default_scope { order("position ASC") }

  def pre_order_tree_traversal
    [self] + child_steps.flat_map(&:pre_order_tree_traversal)
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

  def notify_parent_completed
    if parent
      parent.child_completed!(self)
    else
      proposal.complete!
    end
  end

  def children_completed?
    child_steps.outstanding.empty?
  end
end
