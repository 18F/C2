module Gsa18f
  class TrainingFields
    def initialize(training = nil)
      @training = training
    end

    def relevant
      default
    end

    private

    attr_reader :training

    def default
      [
        :duty_station, :supervisor_id, :title_of_training,
        :training_provider, :purpose, :justification,
        :link, :instructions, :NFS_form, :cost_per_unit,
        :estimated_travel_expenses, :start_date, :end_date
      ]
    end
  end
end
