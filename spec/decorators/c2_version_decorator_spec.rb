describe C2VersionDecorator do
  def escape(str)
    # equivalent to what's used in templates
    ERB::Util.html_escape(str)
  end

  describe '#to_html' do
    it "keeps output marked as unsafe" do
      user = build(:user, first_name: "<script>alert()</script>")
      approval = build(:approval, user: user)
      version = double(C2Version, event: 'create', item: approval)
      decorated = C2VersionDecorator.new(version)

      output = decorated.to_html
      expect(escape(output)).to eq("&lt;script&gt;alert()&lt;/script&gt; #{user.last_name} was added as an approver.")
    end

    it "includes a message for individual approvals" do
      approval = build(:approval)
      version = double(C2Version, event: 'create', item: approval)
      decorated = C2VersionDecorator.new(version)

      approver = approval.user
      expect(decorated.to_html).to eq("#{approver.full_name} was added as an approver.")
    end

    it "doesn't break for unknown classes" do
      version = double(C2Version, event: 'create', item: double)
      decorated = C2VersionDecorator.new(version)
      expect(decorated.to_html).to eq(nil)
    end
  end
end
