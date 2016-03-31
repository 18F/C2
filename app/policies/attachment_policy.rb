class AttachmentPolicy
  include ExceptionPolicy

  def can_destroy!
    check(@user.id == @record.user_id, I18n.t("errors.policies.attachment.destroy_permission"))
  end
end
