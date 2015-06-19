describe 'help pages' do
  let(:doc) { Capybara.string(body) }

  describe 'GET /help' do
    it "renders Markdown successfully" do
      get '/help'

      expect(response.status).to eq(200)
      expect(doc).to have_content('credit card')
    end
  end

  describe 'GET /help/:page' do
    it "renders Markdown successfully" do
      get '/help/new_work_order'

      expect(response.status).to eq(200)
      expect(doc).to have_content('credit card')
      expect(doc).to_not have_content('<%')
      expect(doc).to_not have_content('1. ')
    end
  end
end
