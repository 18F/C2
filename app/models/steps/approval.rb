module Steps
  class Approval < Steps::Individual
    validate :user_is_not_requester

    private

    def user_is_not_requester
      if user && user == proposal.requester
        errors.add(:user, "Cannot be Requester")
      end
    end
  end
end
