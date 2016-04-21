describe MailerHelper do
  describe "#time_and_date" do
    it "respects user timezone" do
      user = create(:user)
      now = Time.current
      user_now = nil
      Time.use_zone user.timezone do
        user_now = now.in_time_zone
      end
      expect(time_and_date(now, user_timezone(user))).to include(user_now.strftime('%I:%M %P'))
    end
  end

  describe "#user_timezone" do
    it "treats nil as default" do
      user = create(:user)
      user.timezone = nil
      expect(user_timezone(user)).to eq(User::DEFAULT_TIMEZONE)
    end

    it "treats empty string as default" do
      user = create(:user)
      user.timezone = ""
      expect(user_timezone(user)).to eq(User::DEFAULT_TIMEZONE)
    end

    it "reflects user-selected timezone" do
      user = create(:user)
      user.timezone = "Central Time (US & Canada)"
      expect(user_timezone(user)).to eq("Central Time (US & Canada)")
    end
  end

  describe '#generate_approve_url' do
    it "returns a URL" do
      approval = create(:approval_step)
      token = create(:api_token, step: approval)
      proposal = approval.proposal

      expect(proposal).to receive(:version).and_return(123)

      url = helper.generate_approve_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.path).to eq("/proposals/#{proposal.id}/complete")
      expect(uri.query_values).to eq(
        'cch' => token.access_token,
        'version' => '123'
      )
    end

    it "throws an error if there's no token" do
      approval = build(:approval_step)
      expect(approval.api_token).to eq(nil)

      expect {
        helper.generate_approve_url(approval)
      }.to raise_error(NoMethodError) # TODO create a more specific error
    end
  end

  describe "step_status_icon" do
    context "step is actionable" do
      it "returns pending icon for step number" do
        step = create(:approval_step, status: "actionable", position: 2)

        icon = step_status_icon(step)

        expect(icon).to eq "icon-number-1-pending.png"
      end
    end

    context "step is pending" do
      it "returns pending icon for step number" do
        step = create(:approval_step, status: "pending", position: 3)

        icon = step_status_icon(step)

        expect(icon).to eq "icon-number-2-pending.png"
      end
    end

    context "step is completed" do
      it "returns completed icon" do
        step = create(:approval_step, status: "completed", position: 4)

        icon = step_status_icon(step)

        expect(icon).to eq "icon-completed.png"
      end
    end
  end
end
