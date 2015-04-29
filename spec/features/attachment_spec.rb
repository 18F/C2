describe "Add attachments" do
  let (:proposal) {
    FactoryGirl.create(:proposal, :with_requester, :with_cart, :with_approvers)
  }
  let! (:attachment) {
    FactoryGirl.create(:attachment, proposal: proposal,
                       user: proposal.requester) }

  before do
    login_as(proposal.requester)
  end

  it "is visible on a proposal" do
    visit proposal_path(proposal)
    expect(page).to have_content(attachment.file_file_name)
  end

  it "uploader can delete" do
    visit proposal_path(proposal)
    expect(page).to have_content("Delete")
    click_on("Delete")
    expect(current_path).to eq("/proposals/#{proposal.id}")
    expect(page).to have_content("Deleted attachment")
    expect(Attachment.count).to be(0)
  end

  it "does not have a delete link for another" do
    login_as(proposal.approvers.first)
    visit proposal_path(proposal)
    expect(page).not_to have_content("Delete")
  end

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

    it "uses an expiring url with aws" do
      visit proposal_path(proposal)
      url = find("#files a")[:href]
      expect(url).to include('my-bucket')
      expect(url).to include('akey')
      expect(url).to include('Expires')
      expect(url).to include('Signature')
      expect(url).not_to include('skey')
    end
  end
end
