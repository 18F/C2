class RequestListDetailSection < SitePrism::Section
  element :public_id_link, "td.public_id a"
  element :status, "td.status"
end

class RequestTableSection < SitePrism::Section
  element :section_title, "h3"
  element :empty_list_label, "p.empty-list-label"
  element :desc_column_header, "th.desc"
  sections :requests, RequestListDetailSection, ".tabular-data tbody tr"
end

class MyRequestsPage < SitePrism::Page
  set_url "/proposals"
  set_url_matcher(%r{\/proposals\/?})

  section :needing_review, RequestTableSection, "#proposals-pending-review"
  section :pending, RequestTableSection, "#proposals-pending"
  section :completed, RequestTableSection, "#proposals-completed"
  section :cancelled, RequestTableSection, "#proposals-cancelled"
end
