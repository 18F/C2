module Ncr
  class WorkOrderSerializer < ActiveModel::Serializer
    attributes(
      :amount,
      :building_number,
      :code,
      :emergency,
      :expense_type,
      :id,
      :not_to_exceed,
      :office,
      :rwa_number,
      :vendor
    )
  end
end
