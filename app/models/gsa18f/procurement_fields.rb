module Gsa18f
  class ProcurementFields
    def initialize(procurement = nil)
      @procurement = procurement
    end

    def relevant(recurring)
      fields = default

      if recurring
        fields += [:recurring, :recurring_interval, :recurring_length]
      end

      fields + [:is_tock_billable, :tock_project]
    end

    private

    attr_reader :procurement

    def default
      [
        :additional_info,
        :cost_per_unit,
        :date_requested,
        :justification,
        :link_to_product,
        :office,
        :product_name_and_description,
        :purchase_type,
        :quantity,
        :urgency
      ]
    end
  end
end
