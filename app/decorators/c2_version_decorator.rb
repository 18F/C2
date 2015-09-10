class C2VersionDecorator < Draper::Decorator
  def to_html
    case object.event
    when 'create'
      case object.item
      when Approval
        approver_name = object.item.user.full_name
        "#{approver_name} was added as an approver."
      when Attachment
        combine_html([
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
        combine_html(changes.compact)
      end
    end
  end

  protected

  def combine_html(strings)
    buffer = ActiveSupport::SafeBuffer.new
    strings.each { |str| buffer << str }
    buffer
  end

  def hashdiff_to_html(change)
    h.content_tag :li do
      change_type = change[0]
      field = change[1]

      case change_type
      when '+' # added
        val = change[2]
        combine_html([
          h.content_tag(:code, field),
          " was set to ",
          h.content_tag(:code, val),
          '.'
        ])
      when '~' # modified
        prev_val = h.diff_val(change[2])
        current_val = h.diff_val(change[3])
        combine_html([
          h.content_tag(:code, field),
          " was changed from ",
          h.content_tag(:code, prev_val),
          " to ",
          h.content_tag(:code, current_val)
        ])
      when '-' # removed
        combine_html([
          h.content_tag(:code, field),
          " was removed."
        ])
      else
        change.inspect
      end
    end
  end
end
