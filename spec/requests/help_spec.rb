describe 'GET /help' do
  it "displays successfully" do
    get '/help'

    expect(response.status).to eq(200)

    doc = Capybara.string(body)
    expect(doc).to have_content('FAQ')

    inset = doc.find('.markdown')
    link = inset.find_link('the homepage')
    expect(link).to_not be_nil
    expect(link[:href]).to eq('/')
  end
end
