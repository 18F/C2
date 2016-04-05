class ProfilePage < SitePrism::Page
  set_url "/profile"

  element :timezone, "#user_timezone"
end
