describe "display sandbox warning" do
  context 'showing sandbox warning' do
    it "on homepage" do
      with_env_var('DISABLE_SANDBOX_WARNING', 'false') do
        visit root_path
        expect(page).to have_content("This sandbox site is for testing and training purposes only")
      end
    end
    it "on internal pages" do
      with_env_var('DISABLE_SANDBOX_WARNING', 'false') do
        visit proposals_path
        expect(page).to have_content("This sandbox site is for testing and training purposes only")
      end
    end
  end

  context 'hides sandbox warning in production' do
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
