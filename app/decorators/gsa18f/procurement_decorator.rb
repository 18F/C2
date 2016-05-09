module Gsa18f
  class ProcurementDecorator < Draper::Decorator
    delegate_all

    def email_display
      [
        [translated_key("purchase_type"), object.purchase_type],
        [translated_key("date_requested"), object.date_requested],
        [translated_key("quantity"), object.quantity],
        [translated_key("urgency"), object.urgency_string],
        [translated_key("cost_per_unit"), object.cost_per_unit],
        [translated_key("office"), object.office],
        [translated_key("total_price"), object.total_price],
        [translated_key("justification"), object.justification],
        [translated_key("link_to_product"), object.link_to_product],
        [translated_key("additional_info"), object.additional_info]
      ]
    end

    def display
      [
        [translated_key("product_name_and_description"), object.product_name_and_description],
        [translated_key("purchase_type"), object.purchase_type],
        [translated_key("justification"), object.justification],
        [translated_key("date_requested"), object.date_requested],
        [translated_key("quantity"), object.quantity],
        [translated_key("cost_per_unit"), object.cost_per_unit],
        [translated_key("total_price"), object.total_price],
        [translated_key("office"), object.office],
        [translated_key("urgency"), object.urgency_string],
        [translated_key("link_to_product"), object.link_to_product],
        [translated_key("additional_info"), object.additional_info]
      ] + recurring_fields
    end

    def new_display
      [
        { key: "office",
          partial: "gsa18f/fields/office" },
        { key: "purchase_type",
          partial: "gsa18f/fields/purchase_type" },
        { key: "product_name_and_description",
          partial: "gsa18f/fields/product_name_and_description" },
        { key: "justification",
          partial: "gsa18f/fields/justification" },
        { key: "link_to_product",
          partial: "gsa18f/fields/link_to_product" },
        { key: "cost_per_unit",
          partial: "gsa18f/fields/cost_per_unit" },
        { key: "quantity",
          partial: "gsa18f/fields/quantity" },
        { key: "recurring",
          partial: "gsa18f/fields/recurring" },
        { key: "date_requested",
          partial: "gsa18f/fields/date_requested" },
        { key: "urgency",
          partial: "gsa18f/fields/urgency" },
        { key: "additional_info",
          partial: "gsa18f/fields/additional_info" }
      ]
    end

    def top_email_field
    end

    def translated_key(key)
      I18n.t("decorators.gsa18f/procurement.#{key}")
    end

    private

    def recurring_fields
      if recurring
        [
          [translated_key("recurring_interval"), object.recurring_interval],
          [translated_key("recurring_length"), object.recurring_length]
        ]
      else
        []
      end
    end
  end
end
