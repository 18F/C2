class Cart < ActiveRecord::Base
  belongs_to :proposal
  include ProposalDelegate

  has_many :api_tokens, through: :approvals
  has_many :properties, as: :hasproperties

  #TODO: validates_uniqueness_of :name

  ORIGINS = %w(navigator ncr gsa18f)


  def fields_for_display
    []
  end

  def client
    'gsa_advantage'
  end

  def public_identifier
    "Cart ##{self.external_id || self.id}"
  end

  # may be replaced with paper-trail or similar at some point
  def version
    self.updated_at.to_i
  end
end
