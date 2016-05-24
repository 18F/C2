require "delegate"

class HistoryEvent < SimpleDelegator
  include ActiveModel::Conversion

  def event_type
    __getobj__.event
  end

  def safe_html_diff
    decorated_version.to_html.html_safe
  end

  def to_partial_path
    "proposals/details/history/" + partial_name
  end

  private

  def decorated_version
    C2VersionDecorator.new(__getobj__)
  end

  def partial_name
    item_type.split("::").last.downcase
  end
end
