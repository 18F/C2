class Observation < ActiveRecord::Base
  has_paper_trail

  belongs_to :proposal
  belongs_to :user

  delegate :full_name, :email_address, to: :user, prefix: true
end
