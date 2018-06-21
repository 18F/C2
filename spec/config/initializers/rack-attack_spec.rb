require 'rails_helper'

describe Rack::Attack, type: :request do
  include Rack::Test::Methods
  before(:each) do
    @period = 60
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.throttle('requests/ip', :limit => 1, :period => @period) { |req| req.ip }
  end

  after(:each) do
    Rack::Attack.cache.store.clear
  end

  context 'throttle requests' do
    it 'make 10 requests and the last response should return error' do
      200.times { get '/', {}, 'REMOTE_ADDR' => '1.2.3.4' }
      expect(last_response.status).to eq 403
    end
  end
end
