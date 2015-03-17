module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  DATA = YAML.load_file("#{Rails.root}/config/data/ncr.yaml")

  class WorkOrder < ActiveRecord::Base
    # In practice, each work order only has one proposal
    has_many :proposals, as: :clientdata

    EXPENSE_TYPES = %w(BA61 BA80)

    BUILDING_NUMBERS = DATA['BUILDING_NUMBERS']
    OFFICES = DATA['OFFICES']

    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true
    validates :office, presence: true

    # Methods for Client Data interface
    def fields_for_display
      exclusions = ["id"]
      attributes = self.attribute_names
      case self.expense_type
      when "BA61"
        exclusions = exclusions.push("rwa_number")
      when "BA80"
        exclusions = exclusions.push("emergency")
      end
      attributes = attributes - exclusions
      attributes.map{|key| [WorkOrder.human_attribute_name(key), self[key]]}
    end
  end
end

