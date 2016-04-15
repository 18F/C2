require "delegate"

# HistoryEvent wraps & delegates to C2Version
class HistoryEvent < SimpleDelegator
  include ActiveModel::Conversion

  def event_type
    model.event
  end

  def comment_text
    # For some reason, paper_trail's "reify" doesn't work with comment versions
    Comment.find(item_id).comment_text
  end

  def attachment
    # "reify" not working with attachment versions either
    Attachment.find(item_id)
  end

  def decorate
    reify.decorate
  end

  def model
    __getobj__
  end

  def to_partial_path
    "proposals/details/history/" + partial_name
  end

  private

  def partial_name
    case item_type
    when "Attachment", "Comment", "Proposal"
      item_type.downcase
    when "Steps::Approval"
      "approval"
    when "Steps::Purchase"
      "purchase"
    else
      item_type
    end
  end
end
