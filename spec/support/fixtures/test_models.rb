module Test
  def self.table_name_prefix
    "test_"
  end

  class ClientRequest < ActiveRecord::Base
    belongs_to :approving_official, class_name: User

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

    def self.expense_type_options
      []
    end
  end

  def self.setup_models
    ClientRequest.connection.create_table :test_client_requests do |t|
      t.decimal  :amount
      t.string   :project_title
      t.integer  :approving_official_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.teardown_models
    ClientRequest.connection.drop_table :test_client_requests
  end

  # we must defer loading the factory till after we have defined our namespace,
  # so call this explicitly to work around rails app load order.
  require Rails.root + "spec/factories/test/client_request.rb"
end
