class ProposalPolicy
  # equivalent of can_show?
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if @user.admin?
        @scope.all
      elsif @user.client_admin?
        Query::Proposals.new(@scope).for_client_slug(@user.client_slug)
      else
        Query::Proposals.new(@scope).which_involve(@user)
      end
    end
  end
end
