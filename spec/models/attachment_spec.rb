require "paperclip/matchers"

describe Attachment do
  include Paperclip::Shoulda::Matchers

  describe "Associations" do
    it { should belong_to(:proposal) }
    it { should belong_to(:user) }
  end

  describe "Validations" do
    it { should have_attached_file(:file) }
    it { should validate_presence_of(:file) }
    it { should validate_presence_of(:proposal) }
    it { should validate_presence_of(:user) }
  end
end
