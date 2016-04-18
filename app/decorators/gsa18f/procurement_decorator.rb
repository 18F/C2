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

    def top_email_field
    end

    private

    def translated_key(key)
      I18n.t("decorators.gsa18f/procurement.#{key}")
    end

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

    def detail_fields_config
      [
        { 
          value: ["office"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["purchase_type"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["product_name_and_description"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["justification"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["link_to_product"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["cost_per_unit"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["quantity"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["recurring"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["date_requested"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["urgency"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["additional_info"],
          style: {
            column: 1,
          },
        },
        { 
          value: ["amount"],
          style: {
            column: 2,
            background: "small-color-card"
          },
        }
      ]
    end
  end
end
