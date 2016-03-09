describe "the return_to url option", elasticsearch: true do
  include ReturnToHelper

  it 'defaults to the proposals listing' do
    login_as(create(:user))
    es_execute_with_retries 3 do
      visit query_proposals_path(text: "test")
      expect(page).to have_content('Back to main portal')
      click_on('Back to main portal')
      expect(current_path).to eq('/proposals')
    end
  end

  let(:return_to) {make_return_to('nnn', '/somewhere_else')}

  it 'changes the link when params are correct' do
    login_as(create(:user))
    es_execute_with_retries 3 do
      visit query_proposals_path(return_to: return_to, text: "test")
      expect(page).not_to have_content('Back to main portal')
      expect(page).to have_content(return_to[:name])
      expect(find_link(return_to[:name])[:href]).to eq(return_to[:path])
    end
  end

  it 'send back to main if not a valid sig (name)' do
    login_as(create(:user))
    different_name = return_to.merge(name: 'other-key-here')
    es_execute_with_retries 3 do
      visit query_proposals_path(return_to: different_name, text: "test")
      expect(page).to have_content('Back to main portal')
      expect(page).not_to have_content(return_to[:name])
      expect(page).not_to have_content('other-key-here')
    end
  end

  it 'send back to main if not a valid sig (name)' do
    login_as(create(:user))
    different_path = return_to.merge(path: 'other-key-here')
    es_execute_with_retries 3 do
      visit query_proposals_path(return_to: different_path, text: "test")
      expect(page).to have_content('Back to main portal')
      expect(page).not_to have_content(return_to[:name])
    end
  end

  it "persists the original request URL over login and redirects after" do
    user = create(:user)
    proposal = create(:proposal, requester: user)

    visit "/proposals/#{proposal.id}"
    expect(current_path).to eq("/")

    login_as(user)

    expect(current_path).to eq("/proposals/#{proposal.id}")
  end
end
