class C2Version < PaperTrail::Version
  self.table_name = :versions

  def user
    User.find_by(id: whodunnit.to_i) || NullUser.new
  end

  def attributes
    if object
      YAML.load(object)
    else
      {}
    end
  end

  def diff
    next_version = self.next || item
    HashDiff.diff((attributes || {}), next_version.attributes)
  end
end
