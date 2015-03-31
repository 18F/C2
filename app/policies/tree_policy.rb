# We may want distinct handing for different authorization failure scenarios.
# In effect, a single "permission" is composed of multiple checks, any of
# which could fail. TreePolicy provides a solution, augmenting Pundit's
# framework to allow both combined boolean guards *and* component checks to
# throw their own warning. See ApplicationController for the other side of
# this implementation
module TreePolicy
  # generally, overridden
  def perm_trees
    {}
  end

  def flatten_tree(key)
    value = self.perm_trees[key]
    if value.nil?   # Base case
      [key]
    elsif value.kind_of?(Array)   # branching tree
      value.flat_map{|k| self.flatten_tree(k) }
    else    # deferring to another query/permission
      self.flatten_tree(value)
    end
  end

  def test_all(key)
    values = self.flatten_tree(key).map{ |k| self.send(k) }
    values.all?
  end
end
