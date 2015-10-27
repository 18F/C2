module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  EXPENSE_TYPES = %w(BA60 BA61 BA80)
  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")
end
