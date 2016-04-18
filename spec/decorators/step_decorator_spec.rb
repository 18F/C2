describe StepDecorator do
  describe "#action_status" do
    it "returns the correct status text" do
      user = build_stubbed(:user)
      step = Steps::Approval.new(user: user).decorate
      step.position = 2
      expect(step.action_status).to eq I18n.t(:action, scope: [:decorators, :steps, :summary],
                                                       display_position: step.position - 1,
                                                       completed: step.completed,
                                                       name: step.completed_by.full_name)
    end
  end

  describe "#label" do
    context "when the step is an approval" do
      it "fetches the correct role text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.label).to eq I18n.t(:label, scope: [:decorators, :steps, :approval])
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct role text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.label).to eq I18n.t(:label, scope: [:decorators, :steps, :purchase])
      end
    end
  end

  describe "#role_name" do
    context "when the step is an approval" do
      it "fetches the correct role text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.role_name).to eq I18n.t(:role_name, scope: [:decorators, :steps, :approval])
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct role text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.role_name).to eq I18n.t(:role_name, scope: [:decorators, :steps, :purchase])
      end
    end
  end

  describe "#action_name" do
    context "when the step is an approval" do
      it "fetches the correct action text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.action_name).to eq I18n.t(:execute_button, scope: [:decorators, :steps, :approval])
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct action text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.action_name).to eq I18n.t(:execute_button, scope: [:decorators, :steps, :purchase])
      end
    end
  end

  describe "#waiting_text" do
    context "when the step is an approval" do
      it "fetches the correct waiting text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.waiting_text).to eq I18n.t("status.waiting", scope: [:decorators, :steps, :approval])
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct waiting text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.waiting_text).to eq I18n.t("status.waiting", scope: [:decorators, :steps, :purchase])
      end
    end
  end

  describe "#completed" do
    context "when the step is an approval" do
      it "fetches the correct completed text" do
        user = build_stubbed(:user)
        step = Steps::Approval.new(user: user).decorate
        expect(step.completed).to eq I18n.t(:completed, scope: [:decorators, :steps, :approval])
      end
    end

    context "when the step is a purchase" do
      it "fetches the correct completed text" do
        user = build_stubbed(:user)
        step = Steps::Purchase.new(user: user).decorate
        expect(step.completed).to eq I18n.t(:completed, scope: [:decorators, :steps, :purchase])
      end
    end
  end
end
