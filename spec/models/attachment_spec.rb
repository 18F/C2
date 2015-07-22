describe Attachment do
  let (:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  let (:attachment) { FactoryGirl.create(:attachment, proposal: proposal, user: proposal.requester) }

  context "aws" do
    before do
      Paperclip::Attachment.default_options.merge!(
        bucket: 'my-bucket',
        s3_credentials: {
          access_key_id: 'akey',
          secret_access_key: 'skey'
        },
        s3_permissions: :private,
        storage: :s3,
      )
    end
    after do
      Paperclip::Attachment.default_options[:storage] = :filesystem
    end

    describe "#url" do
      it "uses an expiring url with aws" do
        url = Addressable::URI.parse(attachment.url)
        query = url.query_values
        expect(url.host).to eq('my-bucket.s3.amazonaws.com')
        expect(query).to have_key('AWSAccessKeyId')
        expect(query['AWSAccessKeyId']).to eq('akey')
        expect(query).to have_key('Expires')
        expect(query).to have_key('Signature')
      end
    end
  end
end
