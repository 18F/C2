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
        # TODO include all Proposals that the user is involved in
        @scope.where(Query::Proposals.for_client_slug(@user.client_slug))
      else
        @scope.where(Query::Proposals.which_involve(@user))
      end
    end
  end
end
