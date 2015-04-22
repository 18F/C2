class ApprovalDelegate < ActiveRecord::Base
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id'
  belongs_to :assigner, class_name: 'User', foreign_key: 'assigner_id'

  validates :assignee_id, presence: true, uniqueness: {scope: :assigner_id}
  validates :assigner_id, presence: true
end
