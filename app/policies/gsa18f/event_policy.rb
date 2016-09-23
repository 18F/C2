module Gsa18f
  class EventPolicy < ProposalPolicy
    include GsaPolicy

    def initialize(user, record)
      super(user, record.proposal)
      @training = record
    end

    def can_create!
      super && gsa_if_restricted!
    end
    alias can_new! can_create!

    def can_cancel!
      not_canceled! && check_user_statuses
    end
    alias can_cancel_form! can_cancel!

    protected

    def check_user_statuses
      check(
        (approver? || delegate? || requester? || admin?) && !purchaser?,
        I18n.t("errors.policies.gsa18f.cancel_permission")
      )
    end

    def purchaser?
      @training.purchaser == @user
    end

    def approver?
      @training.approvers.include?(@user)
    end
  end
end
