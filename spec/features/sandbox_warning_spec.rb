feature "display sandbox warning" do
  include EnvVarSpecHelper

  context "showing sandbox warning" do
    scenario "on homepage" do
      with_env_var('DISABLE_SANDBOX_WARNING', 'false') do
        visit root_path
        expect(page).to have_content("This sandbox site is for testing and training purposes only")
      end
    end

    scenario "on internal pages" do
      with_env_var('DISABLE_SANDBOX_WARNING', 'false') do
        visit proposals_path
        expect(page).to have_content("This sandbox site is for testing and training purposes only")
      end
    end
  end

  context "hides sandbox warning in production" do
    scenario "on homepage" do
      visit root_path
      expect(page).not_to have_content("This sandbox site is for testing and training purposes only")
    end

    scenario "on internal pages" do
      visit proposals_path
      expect(page).not_to have_content("This sandbox site is for testing and training purposes only")
    end
  end
end
