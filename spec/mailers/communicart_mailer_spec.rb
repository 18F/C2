require 'spec_helper'
require 'ostruct'

describe CommunicartMailer do
  describe 'cart notification email' do
    let(:response) { OpenStruct.new(attention: 'attention.to.email@testing.com', cartNumber: '13579', cartItems: []) }
    let(:mail) { CommunicartMailer.cart_notification_email(response) }


    it 'renders the subject' do
      mail.subject.should == 'Please approve Cart Number: 13579'
    end

    it 'renders the receiver email' do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_TO_EMAIL').and_return('george.jetson@spacelysprockets.com')

      mail.to.should == ["attention.to.email@testing.com"]
    end

    it 'renders the sender email' do
      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})

      CommunicartMailer.stub(:default_params).and_return(params)
      mail.from.should == ['reply@communicart-stub.com']
    end
  end
end
