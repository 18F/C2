module FeatureSpecHelper
  def login_with_oauth
    user = create(:user)
    login_as(user)
  end

  def login_as(user)
    setup_mock_auth(:cg, user)
    visit '/auth/cg'
  end

  def fill_in_selectized(selectize_class, text)
    page.execute_script "$('.action-bar-container').toggle()"
    find(".#{selectize_class} .selectize-input input").native.send_keys(text) #fill the input text
    find(:xpath, ("//div[@data-selectable and contains(., '#{text}')]")).click #wait for the input and then click on it
    page.execute_script "$('.action-bar-container').toggle()"
  end

  def expect_page_not_to_have_selectized_options(field, *values)
    values.each do |value|
      within(".#{field}") do
        find(".selectize-control").click
        expect(page).not_to have_content(value)
      end
    end
  end

  def expect_page_to_have_selectized_options(field, *values)
    values.each do |value|
      within(".#{field}") do
        find(".selectize-control").click
        expect(page).to have_content(value)
      end
    end
  end

  def expect_page_to_have_selected_selectize_option(field, text)
    within(".#{field}") do
      find(".selectize-control").click
      within(".dropdown-active") do
        expect(page).to have_content(text)
      end
      find(".selectize-control").click
    end
  end

  def expect_page_not_to_have_selected_selectize_option(field, text)
    within(".#{field}") do
      find(".selectize-control").click
      within(".dropdown-active") do
        expect(page).not_to have_content(text)
      end
      find(".selectize-control").click
    end
  end
end
