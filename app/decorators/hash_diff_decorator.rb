module HashDiffDecorator
  def self.html_for(change)
    change_type = change[0]
    case change_type
    when '+'
      HashDiffDecorator::Added.new(change).to_html
    when '~'
      HashDiffDecorator::Modified.new(change).to_html
    when '-'
      HashDiffDecorator::Removed.new(change).to_html
    else
      change.inspect
    end
  end
end
