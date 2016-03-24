class HeaderSection < SitePrism::Section
  element :summary_link, "a#summary-link"
end

class HomePage < SitePrism::Page
  set_url "/"

  section :header, HeaderSection, "#header"
end
