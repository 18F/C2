class ProposalPolicy
  include TreePolicy

  def perm_trees
    {
      edit?: [:author?, :not_approved?],
      update?: :edit?
    }
  end

  def initialize(user, proposal)
    @user = user
    @proposal = proposal
  end

  def author?
    @proposal.requester_id == @user.id
  end

  def not_approved?
    !@proposal.approved?
  end

  def edit?
    self.test_all(:edit?)
  end

  def update?
    self.edit?
  end
end
