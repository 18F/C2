describe 'GET /help' do
  it "displays successfully" do
    get '/help'
    expect(response.status).to eq(200)
    expect(response.body).to include('FAQ')
  end
end
