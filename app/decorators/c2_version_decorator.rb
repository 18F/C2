class C2VersionDecorator < BaseDecorator
  def to_html
    case object.event
    when 'create'
      self.creation_html
    when 'update'
      self.update_html
    end
  end

  protected

  def user_name
    object.item.user.full_name
  end

  def new_attachment_html
    combine_html([
      "Uploaded ",
      content_tag(:code, object.item.file_file_name),
      '.'
    ])
  end

  def creation_html
    case object.item
    when Approval
      "#{user_name} was added as an approver."
    when Attachment
      self.new_attachment_html
    when Comment
      "Commented: \"#{object.item.comment_text}\""
    when Observation
      "#{user_name} was added as an observer."
    end
  end

  def update_html
    content_tag :ul do
      changes = object.diff.map do |change|
        field = change[1]
        next if %w(created_at updated_at).include?(field)
        hashdiff_to_html(change)
      end
      combine_html(changes.compact)
    end
  end

  def hashdiff_to_html(change)
    content_tag :li do
      HashDiffDecorator.html_for(change)
    end
  end
end
