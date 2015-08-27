class C2Version < PaperTrail::Version
  self.table_name = :versions

  def user
    User.find(self.whodunnit)
  end
end
