class ApprovalDelegate < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'

  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id'
  belongs_to :assigner, class_name: 'User', foreign_key: 'assigner_id'

  validates :assignee_id, presence: true, uniqueness: {scope: :assigner_id}
  validates :assigner_id, presence: true
end
