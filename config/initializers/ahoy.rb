module Ahoy
  class Store < Ahoy::Stores::ActiveRecordStore
    Ahoy.geocode = false
  end
end

