class AdvancedSearchSection < SitePrism::Section
  element :text_search, ".search-terms"
  element :expense_type, "#select_expense_type"
  element :org_code, "#select_org_code"
  element :building_number, "#select_building_number"
end
