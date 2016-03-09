describe UserDelegate do
  describe "Associations" do
    it { should belong_to(:assignee) }
    it { should belong_to(:assigner) }
  end

  describe "Validations" do
    it { should validate_presence_of(:assignee) }
    it { should validate_presence_of(:assigner) }

    it "validates that there is only one record for each assigner and assignee pair" do
      assignee = create(:user)
      assigner = create(:user)

      create(:user_delegate, assigner: assigner, assignee: assignee)
      dupe_delegation = build(:user_delegate, assigner: assigner, assignee: assignee)

      expect(dupe_delegation).not_to be_valid
    end

    it "validates that the assigner and assignee are not the same user" do
      user = create(:user)

      delegation = build(:user_delegate, assigner: user, assignee: user)

      expect(delegation).not_to be_valid
    end
  end
end
