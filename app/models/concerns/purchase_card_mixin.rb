# NOTE must define class method 'purchase_amount_column_name'
# before 'include'-ing this concern
module PurchaseCardMixin
  extend ActiveSupport::Concern
  include FiscalYearMixin

  included do
    def self.max_amount
      fiscals = {
        2015      => 3000,
        2016      => 3500,
        'default' => 3500,
      }
      now = Time.zone.now
      this_fiscal = self.which_fiscal_year(now.year, now.month)
      fiscals[this_fiscal] || fiscals['default']
    end

    validates name.constantize.purchase_amount_column_name, numericality: {
      less_than_or_equal_to: name.constantize.max_amount,
      message: "must be less than or equal to #{ActiveSupport::NumberHelper.number_to_currency(name.constantize.max_amount)}"
    }
    validates name.constantize.purchase_amount_column_name, numericality: {
      greater_than_or_equal_to: 1,
      message: "must be greater than or equal to #{ActiveSupport::NumberHelper.number_to_currency(1)}"
    }
  end
end
