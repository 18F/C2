module Ncr
  class WorkOrderSerializer < ActiveModel::Serializer
    attributes(
      :amount,
      :building_number,
      :code,
      # TODO :description
      :emergency,
      :expense_type,
      :id,
      :not_to_exceed,
      :office,
      :rwa_number,
      :vendor
    )

    has_one :proposal
  end
end
