module Ahoy
  class Store < Ahoy::Stores::ActiveRecordStore
    Ahoy.geocode = false
    Ahoy.visit_duration = 30.minutes
  end
end
