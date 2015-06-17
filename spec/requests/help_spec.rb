describe 'GET /help' do
  it "displays successfully" do
    get '/help'
    expect(response.status).to eq(200)
    doc = Capybara.string(body)
    expect(doc).to have_content('FAQ')
  end
end
