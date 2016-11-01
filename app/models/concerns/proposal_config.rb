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
