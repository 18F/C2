class ProposalPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # returns the entire list of Proposals that are visible to the user
    def resolve
      if @user.admin?
        @scope.all
      elsif @user.client_admin?
        for_client_admin
      else
        @scope.where(ProposalClausesQuery.new.which_involve(@user))
      end
    end

    protected

    def for_client_admin
      @scope.where(
        ProposalClausesQuery.new.for_client_slug(@user.client_slug).or(
          ProposalClausesQuery.new.which_involve(@user)
        )
      )
    end
  end
end
