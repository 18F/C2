require 'spec_helper'

describe Approver do

  context 'required attributes' do
    before do
      @valid_attributes = {
        email_address: 'approver-email@some-dot-gov.gov'
      }
    end
    it 'is valid with valid attributes' do
      approver = Approver.new(@valid_attributes)
      approver.should be_valid
    end

    it "automatically sets a default status of 'pending'" do
      approver = Approver.new(@valid_attributes)
      approver.save
      expect(approver.status).to eq 'pending'
    end

    it 'is invalid without an email address' do
      approver = Approver.new(@valid_attributes)
      approver.email_address = nil
      approver.should_not be_valid
    end
  end

  context 'duplicate approvers' do
    it 'can exist across approval groups' do
      approver1  = Approver.create(email_address: 'test1@test.com', approval_group_id: 1234)
      approver2  = Approver.new(email_address: 'test1@test.com', approval_group_id: 5678)
      approver2.should be_valid
    end

    it 'cannot have duplicate approvers within an approval group' do
      approver1  = Approver.create(email_address: 'test1@test.com', approval_group_id: 1234)
      approver2  = Approver.new(email_address: 'test1@test.com', approval_group_id: 1234)
      approver2.should_not be_valid
    end
  end

end
