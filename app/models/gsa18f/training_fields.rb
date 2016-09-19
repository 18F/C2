module Gsa18f
  class TrainingFields
    def initialize(training = nil)
      @training = training
    end

    def relevant(recurring)
      fields = default

      if recurring
        fields += [:recurring, :recurring_interval, :recurring_length]
      end

      fields
    end

    private

    attr_reader :training

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
