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
    Comment.find(item_id).comment_text # don't know why reify doesn't work here
  end

  def attachment
    Attachment.find(item_id)
  end

  # TODO: Move some of this into StepDecorator

  def step_count
    reify.position - 1
  end

  def step_action_description
    step = reify.decorate
    "Step " + step_count.to_s + ": " +
      step.completed + " by " + step.completed_by.full_name
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
    end
  end
end
