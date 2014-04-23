require 'spec_helper'
require 'ostruct'

describe CommunicartMailer do
  describe 'cart notification email' do
    let(:analysis) { OpenStruct.new(email: 'email.to.email@testing.com', cartNumber: '13579', cartItems: []) }
    let(:mail) { CommunicartMailer.cart_notification_email(analysis.email, analysis) }

    it 'renders the subject' do
      mail.subject.should == 'Please approve Cart Number: 13579'
    end

    it 'renders the receiver email' do
      mail.to.should == ["email.to.email@testing.com"]
    end

    it 'renders the sender email' do
      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})

      CommunicartMailer.stub(:default_params).and_return(params)
      mail.from.should == ['reply@communicart-stub.com']
    end
  end

  describe 'approval reply received email' do
    let(:analysis) {
      OpenStruct.new(
                    approve: 'APPROVE',
                    fromAddress: 'approver-test@some-dot-gov.gov',
                    cartNumber: '13579'
                    )
    }

    let(:report) {
      OpenStruct.new(
                    cart: FactoryGirl.create(:cart_with_approval_group_and_requester)
                    )
    }

    let(:mail) { CommunicartMailer.approval_reply_received_email(analysis, report) }


    it 'renders the subject' do
      mail.subject.should == 'User approver-test@some-dot-gov.gov has approved cart #13579'
    end

    it 'renders the receiver email' do
      mail.to.should == ["cart-requester@some-dot.gov"]
    end

    it 'renders the sender email' do
      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})

      CommunicartMailer.stub(:default_params).and_return(params)
      mail.from.should == ['reply@communicart-stub.com']
    end
  end
end
