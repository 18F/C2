describe StepDecorator do
  describe "#role_name" do
    context "when the step is an approval" do
      it "fetches the correct role text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.role_name).to eq "Approver"
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct role text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.role_name).to eq "Purchaser"
      end
    end
  end

  describe "#action_name" do
    context "when the step is an approval" do
      it "fetches the correct action text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.action_name).to eq "Approve"
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct action text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.action_name).to eq "Mark as Purchased"
      end
    end
  end

  describe "#waiting_text" do
    context "when the step is an approval" do
      it "fetches the correct waiting text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.waiting_text).to eq "Waiting for review from:"
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct waiting text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.waiting_text).to eq "Waiting for purchase from:"
      end
    end
  end
end
