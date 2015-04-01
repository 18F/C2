describe TreePolicy do
  class TestClass
    include TreePolicy
    
    def perm_trees
      {
        level2: [:level1],
        level1: [:success1, :failure],
        only_success: [:success1, :success2]
      }
    end

    def success1
      true
    end

    def success2
      true
    end

    def failure
      false
    end
  end

  describe "#flatten_tree" do
    it "doesn't expand leaves" do
      expect(TestClass.new.flatten_tree(:success1)).to eq([:success1])
      expect(TestClass.new.flatten_tree(:other)).to eq([:other])
    end
    it "recursively expands" do
      expect(TestClass.new.flatten_tree(:only_success)).to eq(
        [:success1, :success2])
      expect(TestClass.new.flatten_tree(:level1)).to eq(
        [:success1, :failure])
      expect(TestClass.new.flatten_tree(:level2)).to eq(
        [:success1, :failure])
    end
  end

  describe "#test_all" do
    it "evaluates leaves" do
      expect(TestClass.new.test_all(:success1)).to be(true)
      expect(TestClass.new.test_all(:success2)).to be(true)
      expect(TestClass.new.test_all(:failure)).to be(false)
    end
    it "ANDs together expanded nodes" do
      expect(TestClass.new.test_all(:level2)).to be(false)
      expect(TestClass.new.test_all(:level1)).to be(false)
      expect(TestClass.new.test_all(:only_success)).to be(true)
    end
  end
end
