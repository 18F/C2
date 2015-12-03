describe StepDecorator do
  describe "#role_name" do
    let(:user) { create(:user) }

    context "when the step is an approval" do
      it "fetches the correct role text" do
        step = Steps::Approval.new(user: user).decorate
        expect(step.role_name).to eq "Approver"
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct role text" do
        step = Steps::Purchase.new(user: user).decorate
        expect(step.role_name).to eq "Purchaser"
      end
    end
  end

  describe "#action_name" do
    let(:user) { create(:user) }

    context "when the step is an approval" do
      it "fetches the correct action text" do
        step = Steps::Approval.new(user: user).decorate
        expect(step.action_name).to eq "Approve"
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct action text" do
        step = Steps::Purchase.new(user: user).decorate
        expect(step.action_name).to eq "Mark as Purchased"
      end
    end
  end
end
