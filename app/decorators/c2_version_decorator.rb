class C2VersionDecorator < BaseDecorator
  def to_html
    case object.event
    when "create"
      creation_html
    when "update"
      update_html
    when "destroy"
      destroy_html
    end
  end

  protected

  def user_name
    object.item.user.full_name
  end

  def creation_html
    case object.item
    when Steps::Individual
      "#{user_name} was added as an approver."
    when Comment
      "Commented: \"#{object.item.comment_text}\""
    when Observation
      "#{user_name} was added as an observer."
    else
      ""
    end
  end

  def update_html
    content_tag :ul do
      changes = object.diff.map do |change|
        field = change[1]
        next if %w(created_at updated_at).include?(field)
        change_hash = { type: change[0],
                        field: field,
                        val1: change[2],
                        val2: change[3],
                        object: reify.decorate }
        hashdiff_to_html(change_hash)
      end
      combine_html(changes.compact)
    end
  end

  def destroy_html
    destroyed = object.reify
    destroyed.file_file_name.to_s
  end

  def hashdiff_to_html(change)
    content_tag :li do
      HashDiffDecorator.html_for(change)
    end
  end
end
