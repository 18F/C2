class MigrateNcrToModels < ActiveRecord::Migration
  class TempProperty < ActiveRecord::Base
    self.table_name = 'properties'
  end

  class TempCart < ActiveRecord::Base
    self.table_name = 'carts'
    has_many :properties, -> { where hasproperties_type: 'Cart' },
              foreign_key: "hasproperties_id",
              class_name: 'TempProperty'
    belongs_to :proposal
    def props
      Hash[self.properties.collect{|p| [p.property, YAML::load(p.value)]}]
    end
  end

  class TempProposal < ActiveRecord::Base
    self.table_name = 'proposals'
    has_one :cart, class_name: 'TempCart'
  end

  class TempNcrWorkOrder < ActiveRecord::Base
    self.table_name = 'ncr_work_orders'
    has_many :proposals, -> { where client_data_type: 'Ncr::WorkOrder' },
              foreign_key: "client_data_id"
  end

  def up
    carts = TempCart.joins(:properties)
                .where(properties: {property: "origin"})
                .where("properties.value like '%ncr%'")
    carts.find_each { |cart|
      props = cart.props
      work_order = TempNcrWorkOrder.create(
        amount: props["amount"],
        expense_type: props["expense_type"],
        vendor: props["vendor"],
        not_to_exceed: props["not_to_exceed"],
        building_number: props["building_number"],
        emergency: props["emergency"],
        rwa_number: props["rwa_number"],
        office: props["office"])
      cart.proposal.client_data_type = 'Ncr::WorkOrder'
      cart.proposal.client_data_id = work_order.id
      cart.proposal.save()
      cart.properties.destroy_all
    }
  end
  def down
    TempNcrWorkOrder.includes(:proposals).find_each{ |work_order|
      proposal = work_order.proposals.first
      proposal.client_data_id = nil
      proposal.client_data_type = nil
      proposal.save()
      cart = proposal.cart
      TempProperty.create(
        property: 'origin',
        value: YAML::dump('ncr'),
        hasproperties_id: cart.id,
        hasproperties_type: 'Cart'
      )
      [:amount, :expense_type, :vendor, :not_to_exceed, :building_number,
       :emergency, :rwa_number, :office].each{ |field|
        value = work_order[field]
        if !value.nil?
          TempProperty.create(
            property: field,
            value: YAML::dump(value.to_s),
            hasproperties_id: cart.id,
            hasproperties_type: 'Cart'
          )
        end
      }
      work_order.destroy
    }
  end
end
