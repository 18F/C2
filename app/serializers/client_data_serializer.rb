class ClientDataSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object
end
