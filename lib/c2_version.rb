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
    HashDiff.diff((attributes || {}), hash_with_utc_times(next_version.attributes))
  end

  private

  def hash_with_utc_times(hash)
    hash.each do |key, value|
      if value.is_a?(Time) && value.respond_to?(:utc)
        hash[key] = value.utc
      end
    end
    hash
  end
end
