class ObservationPolicy
  include ExceptionPolicy

  def can_destroy!
    role = Role.new(@user, @record.proposal)
    check(@user.id == @record.user_id || role.client_admin? || @user.admin?,
          "Only the observer can delete themself")
  end
end
