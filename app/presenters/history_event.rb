require "delegate"

class HistoryEvent < SimpleDelegator
  include ActiveModel::Conversion

  def event_type
    __getobj__.event
  end

  def decorated_version
    C2VersionDecorator.new(__getobj__)
  end

  def to_partial_path
    "proposals/details/history/" + partial_name
  end

  private

  def partial_name
    item_type.split("::").last.downcase
  end
end
