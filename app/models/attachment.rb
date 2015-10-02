class Attachment < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'
  has_attached_file :file
  do_not_validate_attachment_file_type :file

  validates_presence_of :file
  validates_presence_of :proposal
  validates_presence_of :user

  belongs_to :proposal
  belongs_to :user

  scope :with_users, -> { includes :user }

  # Default url for attachments expires after 10 minutes
  def url
    self.file.expiring_url(10*60)
  end
end
