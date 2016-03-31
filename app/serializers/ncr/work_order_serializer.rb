module Ncr
  class WorkOrderSerializer < ActiveModel::Serializer
    # make sure to keep docs/api.md up-to-date

    attributes(
      :amount,
      :building_number,
      :description,
      :emergency,
      :expense_type,
      :id,
      :name,
      :not_to_exceed,
      :organization_code_and_name,
      :rwa_number,
      :vendor,
      :work_order_code
    )

    has_one :proposal
    has_many :observers
  end
end
