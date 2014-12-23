describe 'White House Service Center proposals' do
  describe 'GET /whsc/proposals/new' do
    it "renders the form" do
      get '/whsc/proposals/new'
      expect(response.body).to include('Purchase Request')
    end
  end
end
