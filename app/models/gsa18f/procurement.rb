module Gsa18f
  # Make sure all table names use 'gsa18f_XXX'
  def self.table_name_prefix
    'gsa18f_'
  end

  DATA = YAML.load_file("#{Rails.root}/config/data/18f.yaml")


  class Procurement < ActiveRecord::Base
    URGENCY = DATA['URGENCY']
    OFFICES = DATA['OFFICES']
    RECURRENCE = DATA['RECURRENCE']

    has_one :proposal, as: :client_data
    include ProposalDelegate

    validates :cost_per_unit, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :quantity, numericality: {
      greater_than_or_equal_to: 1
    }
    validates :product_name_and_description, presence: true

    after_create :add_approvals


    def add_approvals
      self.add_approver(Gsa18f::Procurement.approver_email)
      self.proposal.initialize_approvals()
    end

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(recurring)
      fields = [:office, :justification, :link_to_product, :quantity,
        :date_requested, :urgency, :additional_info, :cost_per_unit,
        :product_name_and_description, :recurring]
      if recurring
        fields += [:recurring_interval, :recurring_length]
      end
      fields
    end

    def relevant_fields
      Gsa18f::Procurement.relevant_fields(self.recurring)
    end

    def fields_for_display
      attributes = self.relevant_fields
      attributes.map! {|key| [Procurement.human_attribute_name(key), self[key]]}
      attributes.push(["Total Price", total_price])
    end

    def client
      "gsa18f"
    end

    # @todo - this is pretty ugly
    def public_identifier
      "##{self.proposal.id}"
    end

    def total_price
      (self.cost_per_unit * self.quantity) || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      self.updated_at.to_i
    end

    def name
      self.product_name_and_description
    end

    def self.approver_email
      ENV['GSA18F_APPROVER_EMAIL'] || '18fapprover@gsa.gov'
    end
  end
end
