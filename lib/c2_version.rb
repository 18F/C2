class C2Version < PaperTrail::Version
  self.table_name = :versions

  def user
    User.find(self.whodunnit)
  end

  def attributes
    if self.object
      YAML.load(self.object)
    else
      {}
    end
  end

  def diff
    case self.event
    when 'create'
      HashDiff.diff({}, self.attributes)
    when 'update'
      prev = self.previous
      HashDiff.diff(prev.attributes, self.attributes)
    else
      # not sure what makes the most sense here...
      nil
    end
  end
end
