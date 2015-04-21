class Observation < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user

  delegate :full_name, :email_address, to: :user, prefix: true
end
