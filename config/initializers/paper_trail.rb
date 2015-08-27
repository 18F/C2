# some overrides of the gem
PaperTrail::Version.class_eval do
  def user
    User.find(self.whodunnit)
  end
end
