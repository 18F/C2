describe C2Version do
  describe "#diff" do
    it "compares this version (before) with the next (after)" do
      test_client_request = create(:test_client_request)
      test_client_request.project_title = "something different"
      test_client_request.save!
      versions = test_client_request.versions
      expect(versions.count).to eq(2)
      expect(versions.last.diff[1]).to eq(["~", "project_title", "I am a test request", "something different"])
    end
  end
end
