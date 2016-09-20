module Gsa18f
  class TrainingDecorator < Draper::Decorator
    delegate_all

    def client_code
      "gsa18f"
    end

    def email_display
      new_display.map do |field|
        [translated_key(field), object[field]]
      end
    end

    def display
      email_display
    end

    def new_display
      %w(duty_station supervisor_id title_of_training training_provider purpose justification link instructions nfs_form cost_per_unit estimated_travel_expenses start_date end_date)
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
