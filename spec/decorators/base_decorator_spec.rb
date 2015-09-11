describe BaseDecorator do
  def escape(str)
    # equivalent to what's used in templates
    ERB::Util.html_escape(str)
  end

  describe '.combine_html' do
    it "escapes content" do
      output = BaseDecorator.combine_html(["<script>alert()</script>"])
      expect(escape(output)).to eq("&lt;script&gt;alert()&lt;/script&gt;")
    end
  end
end
