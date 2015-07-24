if BULLET_ENABLED
  RSpec.configure do |config|
    config.before(:suite) do
      Bullet.raise = true
    end

    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
