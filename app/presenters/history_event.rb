require "delegate"

class HistoryEvent < SimpleDelegator
  include ActiveModel::Conversion

  def event_type
    model.event
  end

  def user
    User.find whodunnit
  end

  def comment_text
    if item_type == "Comment"
      Comment.find(item_id).comment_text
    end
  end

  def attachment
    if item_type == "Attachment"
      Attachment.find(item_id)
    end
  end

  def model
    __getobj__
  end

  def to_partial_path
    "proposals/details/history/" + partial_name
  end

  def partial_name
    case item_type
    when "Attachment", "Comment", "Proposal"
      item_type.downcase
    when "Steps::Approval"
      "approval"
    when "Steps::Purchase"
      "purchase"
    end
  end
end
