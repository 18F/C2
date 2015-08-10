class ObservationPolicy
  include ExceptionPolicy

  def can_destroy!
    check(@user.id == @record.user_id || @user.client_admin? || @user.admin?,
          "Only the observer can delete themself")
  end
end
