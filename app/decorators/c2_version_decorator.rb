class C2VersionDecorator < Draper::Decorator
  def to_html
    case object.event
    when 'create'
      case object.item
      when Approval
        approver_name = object.item.user.full_name
        "#{approver_name} was added as an approver."
      when Attachment
        self.class.combine_html([
          "Uploaded ",
          h.content_tag(:code, object.item.file_file_name),
          '.'
        ])
      when Comment
        "Commented: \"#{object.item.comment_text}\""
      when Observation
        observer_name = object.item.user.full_name
        "#{observer_name} was added as an observer."
      end
    when 'update'
      h.content_tag :ul do
        changes = object.diff.map do |change|
          field = change[1]
          next if %w(created_at updated_at).include?(field)
          hashdiff_to_html(change)
        end
        self.class.combine_html(changes.compact)
      end
    end
  end

  def self.combine_html(strings)
    buffer = ActiveSupport::SafeBuffer.new
    strings.each { |str| buffer << str }
    buffer
  end

  protected

  def hashdiff_to_html(change)
    h.content_tag :li do
      HashDiffDecorator.html_for(change)
    end
  end
end
