describe "the return_to url option" do
  include ReturnToHelper

  before do
    login_as(FactoryGirl.create(:user))
  end

  it 'defaults to the proposals listing' do
    visit '/proposals/query'
    expect(page).to have_content('Back to main portal')
    click_on('Back to main portal')
    expect(current_path).to eq('/proposals')
  end

  let(:return_to) {make_return_to('nnn', '/somewhere_else')}

  it 'changes the link when params are correct' do
    visit query_proposals_path(return_to: return_to)
    expect(page).not_to have_content('Back to main portal')
    expect(page).to have_content(return_to[:name])
    expect(find_link(return_to[:name])[:href]).to eq(return_to[:path])
  end

  it 'validates sig (name)' do
    different_name = return_to.merge(name: 'other')
    visit query_proposals_path(return_to: different_name)
    expect(page).to have_content('Back to main portal')
    expect(page).not_to have_content(return_to[:name])
    expect(page).not_to have_content('other')
  end

  it 'validates sig (path)' do
    different_path = return_to.merge(path: 'other')
    visit query_proposals_path(return_to: different_path)
    expect(page).to have_content('Back to main portal')
    expect(page).not_to have_content(return_to[:name])
  end
end
