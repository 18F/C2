describe C2VersionDecorator do
  def escape(str)
    # equivalent to what's used in templates
    ERB::Util.html_escape(str)
  end

  describe '#to_html' do
    it "keeps output marked as unsafe" do
      user = FactoryGirl.build(:user, first_name: "<script>alert()</script>")
      approval = FactoryGirl.build(:approval, user: user)
      version = double(C2Version, event: 'create', item: approval)
      decorated = C2VersionDecorator.new(version)

      output = decorated.to_html
      expect(escape(output)).to eq("&lt;script&gt;alert()&lt;/script&gt; Thunder was added as an approver.")
    end
  end

  describe '#combine_html' do
    it "escapes content" do
      version = double(C2Version)
      decorated = C2VersionDecorator.new(version)

      output = decorated.send(:combine_html, ["<script>alert()</script>"])
      expect(escape(output)).to eq("&lt;script&gt;alert()&lt;/script&gt;")
    end
  end
end
