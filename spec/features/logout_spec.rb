# This is both a feature and a controller spec and the controller spec doesn't test the route
describe "Logging out" do
  context 'a user is signed in' do
    before do
      login_as(FactoryGirl.create(:user))
    end

    it 'allows logout via the header link' do
      visit '/'
      expect(page).not_to have_content('Sign in')
      expect(page).to have_content('Logout')
      click_on 'Logout'
      expect(current_path).to eq('/')
      expect(page).to have_content('Sign in')
      expect(page).not_to have_content('Logout')
    end

    it 'allows logout via a url' do
      visit '/'
      expect(page).not_to have_content('Sign in')
      expect(page).to have_content('Logout')
      visit '/logout'   # hard page refresh
      expect(current_path).to eq('/')
      expect(page).to have_content('Sign in')
      expect(page).not_to have_content('Logout')
    end
  end
end
