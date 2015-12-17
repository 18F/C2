class C2Version < PaperTrail::Version
  self.table_name = :versions

  def user
    User.find_by(id: whodunnit.to_i)
  end

  def attributes
    if object
      YAML.load(object)
    else
      {}
    end
  end

  def diff
    case event
    when 'create'
      HashDiff.diff({}, attributes)
    when 'update'
      prev = previous
      HashDiff.diff(prev.attributes, attributes)
    else
      # not sure what makes the most sense here...
      nil
    end
  end
end
