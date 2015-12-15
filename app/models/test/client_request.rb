module Test
  def self.table_name_prefix
    "test_"
  end

  class ClientRequest < ActiveRecord::Base
    # must define before include PurchaseCardMixin
    def self.purchase_amount_column_name
      :amount
    end

    include ClientDataMixin
    include PurchaseCardMixin

    def editable?
      true
    end

    def name
      project_title
    end
  end
end
