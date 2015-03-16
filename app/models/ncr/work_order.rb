module Ncr
  DATA = YAML.load_file("#{Rails.root}/config/data/ncr.yaml")

  class WorkOrder < ActiveRecord::Base

    EXPENSE_TYPES = %w(BA61 BA80)

    BUILDING_NUMBERS = DATA['BUILDING_NUMBERS']
    OFFICES = DATA['OFFICES']

    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :description, presence: true
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true
    validates :office, presence: true
  end
end

