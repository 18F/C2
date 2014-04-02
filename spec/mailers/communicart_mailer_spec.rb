require 'spec_helper'
require 'ostruct'

describe CommunicartMailer do
  describe 'cart notification email' do
    let(:user) { OpenStruct.new(first_name: 'George', last_name: 'Jetson', email: 'lucas@email.com') }
    let(:mail) { CommunicartMailer.cart_notification_email(user) }

    it 'renders the subject' do
      mail.subject.should == 'You have received a Communicart notification'
    end

    it 'renders the receiver email' do
      mail.to.should == ["george.jetson@spacelysprockets.com"]
    end

    it 'renders the sender email' do
      mail.from.should == ['reply@communicart-stub.com']
    end
  end
end