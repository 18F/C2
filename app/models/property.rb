class Property < ActiveRecord::Base
  belongs_to :hasproperties, polymorphic: true
end
