class Cart < ActiveRecord::Base
  include PropMixin

  belongs_to :proposal
  include ProposalDelegate

  has_one :approval_group
  has_many :user_roles, through: :approval_group
  has_many :api_tokens, through: :approvals
  has_many :properties, as: :hasproperties

  #TODO: validates_uniqueness_of :name

  ORIGINS = %w(navigator ncr gsa18f)


  # Some fields aren't meant for the clients' eyes
  EXCLUDE_FIELDS_FROM_DISPLAY = ['origin', 'contractingVehicle', 'location', 'configType']
  # The following methods are an interface which should be matched by client
  # models
  def fields_for_display
    self.properties_with_names.reject{ |key,value,label|
      EXCLUDE_FIELDS_FROM_DISPLAY.include? key}.map{ |key,value,label|
      [label, value] }
  end

  def client
    self.getProp('origin') || 'gsa_advantage'
  end

  def public_identifier
    "Cart ##{self.external_id || self.id}"
  end

  # may be replaced with paper-trail or similar at some point
  def version
    self.updated_at.to_i
  end
end
