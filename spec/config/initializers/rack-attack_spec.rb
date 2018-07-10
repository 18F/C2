require 'rails_helper'

describe Rack::Attack, type: :request do
  include Rack::Test::Methods
  before(:each) do
    @period = 60
    @limit = 5
    @ip = '1.2.3.4'
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.throttle('requests/ip', :limit => @limit - 1, :period => @period) { |req| req.ip }
  end

  after(:each) do
    Rack::Attack.cache.store.clear
  end

  context 'throttle requests' do
    it 'make 5 requests and the last response should return have http status of "too_many_requests" (429)' do
      @limit.times do
        get "/", headers: { REMOTE_ADDR: @ip }
      end
      expect(last_response.status).to eq(429) # 429 is same as too_many_requests
    end
  end
end
