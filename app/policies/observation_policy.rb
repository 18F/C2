class ObservationPolicy
  include ExceptionPolicy

  def initialize(user, record)
    super(user, record)
    @observation = record
  end

  def can_create!
    can_show_proposal!
  end

  def can_destroy!
    can_show_proposal! || user_is_observer!
  end

  protected

  def can_show_proposal!
    policy = PolicyFinder.policy_for(@user, @observation.proposal)
    policy.can_show!
  end

  def user_is_observer!
    @user == @observation.user
  end
end
