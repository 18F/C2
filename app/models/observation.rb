class Observation < ProposalRole
  belongs_to :user
  belongs_to :proposal

  validates :user_id, presence: true
  validates :proposal_id, presence: true


  delegate :full_name, :email_address, to: :user, prefix: true

  after_initialize :init

  def init
    self.role_id ||= Role.find_or_create_by(name: 'observer').id
  end

  def creation_version
    versions.find_by(event: 'create')
  end

  def created_by
    creation_version.try(:user)
  end
end
