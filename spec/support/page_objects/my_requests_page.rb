class RequestListDetailSection < SitePrism::Section
  element :public_id_link, "td:nth-child(1) a"
end

class RequestTableSection < SitePrism::Section
  element :section_title, "h3"
  sections :requests, RequestListDetailSection, ".tabular-data tbody tr"
end

class MyRequestsPage < SitePrism::Page
  set_url "/proposals"
  set_url_matcher(/\/proposals\/?/)

  section :needing_review, RequestTableSection, "#proposals-pending-review"
end
