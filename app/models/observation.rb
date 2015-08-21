class Observation < ActiveRecord::Base
  has_paper_trail

  belongs_to :proposal
  belongs_to :user

  delegate :full_name, :email_address, to: :user, prefix: true

  def created_by_id
    creation = self.versions.find_by(event: 'create')
    creation.try(:whodunnit)
  end

  def created_by
    # don't throw an exception if the ID is nil
    User.find_by(id: self.created_by_id)
  end
end
