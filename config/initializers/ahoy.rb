module Ahoy
  class Store < Ahoy::Stores::ActiveRecordStore
    Ahoy.geocode = false
    Ahoy.mount = false
  end
end
