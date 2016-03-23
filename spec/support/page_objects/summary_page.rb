class SummaryRowsSection < SitePrism::Section
  element :status, "th"
  element :status_count, "td span.status_count"
end

class SummaryTableSection < SitePrism::Section
  sections :rows, SummaryRowsSection, "tr.status"
end

class SummaryPage < SitePrism::Page
  set_url "/summary"

  sections :tables, SummaryTableSection, "table.summary-table"
end
