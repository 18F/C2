class Attachment < ActiveRecord::Base
  has_attached_file :file
  do_not_validate_attachment_file_type :file

  validates_presence_of :file
  validates_presence_of :proposal
  validates_presence_of :user

  belongs_to :proposal
  belongs_to :user
end
