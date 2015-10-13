module HashDiffDecorator
  def self.html_for(change)
    case change[0] # change type
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
