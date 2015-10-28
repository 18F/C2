if defined?(Konacha)
  Konacha.configure do |config|
    require 'capybara/poltergeist'
    config.driver = :poltergeist
  end
end
