module ProposalConfig
  extend ActiveSupport::Concern

  included do
    has_many :steps
    has_many :approval_steps, class_name: "Steps::Approval"
    has_many :purchase_steps, class_name: "Steps::Purchase"
    has_many :completers, through: :steps, source: :completer

    has_many :api_tokens, through: :steps
    has_many :attachments, dependent: :destroy
    has_many :comments, -> { order(created_at: :desc) }, dependent: :destroy

    has_many :observations, -> { where("proposal_roles.role_id in (select roles.id from roles where roles.name='#{ROLE_OBSERVER}')") }
    has_many :observers, through: :observations, source: :user
    belongs_to :client_data, polymorphic: true, dependent: :destroy
    belongs_to :requester, class_name: "User"

    validates :requester_id, presence: true
    validates :public_id, uniqueness: true, allow_nil: true
  end

  def add_completed_comment
    completer = individual_steps.last.completed_by
    comments.create_without_callback(
      comment_text: I18n.t(
        "activerecord.attributes.proposal.user_completed_comment",
        user: completer.full_name
      ),
      update_comment: true,
      user: completer
    )
  end
end
