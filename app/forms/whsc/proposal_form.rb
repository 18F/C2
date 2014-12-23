module Whsc
  class ProposalForm
    include SimpleFormObject

    attribute :amount, :decimal
    attribute :description, :text
    attribute :vendor, :string
  end
end
