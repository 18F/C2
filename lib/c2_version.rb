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

  def live_version
    item
  end

  def diff
    next_version = self.next || live_version
    HashDiff.diff((attributes || {}), next_version.attributes)
  end
end
