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
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_TO_EMAIL').and_return('george.jetson@spacelysprockets.com')
      mail.to.should == ["george.jetson@spacelysprockets.com"]
    end

    it 'renders the sender email' do
      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})

      CommunicartMailer.stub(:default_params).and_return(params)
      mail.from.should == ['reply@communicart-stub.com']
    end
  end
end