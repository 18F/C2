module Gsa18f
  class ProcurementFields
    def initialize(procurement = nil)
      @procurement = procurement
    end

    def relevant(recurring)
      fields = default

      if recurring
        fields += [:recurring_interval, :recurring_length]
      end

      fields
    end

    def display
      attributes_for_view.push(["Total Price", procurement.total_price])
    end

    def email_display
      [
        ["Purchase Type", procurement.purchase_type],
        ["Date Requested", procurement.date_requested],
        ["Quantity", procurement.quantity],
        ["Urgency", procurement.urgency_string],
        ["Cost Per Unit", procurement.cost_per_unit],
        ["Office", procurement.office],
        ["Total Price", procurement.total_price],
        ["Justification", procurement.justification],
        ["Link to Product", procurement.link_to_product],
        ["Additional Info", procurement.additional_info]
      ]
    end

    def top_email_field
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
        :urgency,
      ]
    end

    def attributes_for_view
      relevant(procurement.recurring).map do |attribute|
        [Gsa18f::Procurement.human_attribute_name(attribute), procurement.send(attribute)]
      end
    end
  end
end
