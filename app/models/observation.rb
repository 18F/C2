class Observation < ProposalRole
  has_paper_trail

  belongs_to :user
  belongs_to :proposal

  validates :user_id, presence: true
  validates :proposal_id, presence: true


  delegate :full_name, :email_address, to: :user, prefix: true

  after_initialize :init

  def init
    self.role_id ||= Role.find_or_create_by(name: 'observer').id
  end

  def created_by_id
    creation = self.versions.find_by(event: 'create')
    creation.try(:whodunnit)
  end

  def created_by
    # don't throw an exception if the ID is nil
    User.find_by(id: self.created_by_id)
  end
end
