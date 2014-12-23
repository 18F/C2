module Whsc
  class ProposalForm
    include SimpleFormObject

    attribute :amount, :decimal
    attribute :name, :string
    attribute :vendor, :string
  end
end
