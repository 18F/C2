describe "display sandbox warning" do
  context 'showing sandbox warning' do
    it "on homepage" do
      visit root_path
      expect(page).to have_content("This sandbox site is for testing and training purposes only")
    end
    it "on internal pages" do
      visit proposals_path
      expect(page).to have_content("This sandbox site is for testing and training purposes only")
    end
  end

  context 'hides sandbox warning in production' do
    with_feature 'DISABLE_SANDBOX_WARNING' do
      it "on homepage" do
        visit root_path
        expect(page).not_to have_content("This sandbox site is for testing and training purposes only")
      end

      it "on internal pages" do
        visit proposals_path
        expect(page).not_to have_content("This sandbox site is for testing and training purposes only")
      end
    end
  end
end