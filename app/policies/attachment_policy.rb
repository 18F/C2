class AttachmentPolicy
  include ExceptionPolicy

  def can_destroy!
    check(@user.id == @record.user_id,
          "Only the original author can delete an attachment")
  end
end
