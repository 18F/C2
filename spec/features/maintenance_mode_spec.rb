feature "maintenance mode" do
  include EnvVarSpecHelper

  context "showing maintenance page" do
    scenario "on home page" do
      with_env_var("MAINTENANCE_MODE", "true") do
        visit root_path
        expect(page).to have_content("This site is currently down")
      end
    end

    scenario "on internal pages" do
      with_env_var("MAINTENANCE_MODE", "true") do
        visit proposals_path
        expect(page).to have_content("This site is currently down")
      end
    end

    scenario "in API response" do
      with_env_var("MAINTENANCE_MODE", "true") do
        visit api_v2_proposals_path
        expect(page).to have_content("The site is down")
      end
    end
  end
end
