module Ncr
  class WorkOrderSerializer < ActiveModel::Serializer
    # make sure to keep docs/api.md up-to-date

    attributes(
      :amount,
      :building_number,
      :code,
      :created_at,
      :description,
      :emergency,
      :expense_type,
      :flow,
      :id,
      :name,
      :not_to_exceed,
      :office,
      :rwa_number,
      :status,
      :updated_at,
      :vendor
    )

    has_one :requester
    has_many :approvals
  end
end
