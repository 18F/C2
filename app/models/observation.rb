class Observation < ActiveRecord::Base
  has_paper_trail

  belongs_to :proposal
  belongs_to :user

  delegate :full_name, :email_address, to: :user, prefix: true

  def creation_version
    self.versions.find_by(event: 'create')
  end

  def created_by
    self.creation_version.try(:user)
  end
end
