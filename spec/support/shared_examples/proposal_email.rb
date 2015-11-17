shared_examples "a proposal email" do
  it "renders the subject" do
    expect(mail.subject).to eq("Request #{proposal.public_id}")
  end

  it "uses the configured sender email" do
    expect(mail.from).to eq(['reply@example.com'])
  end

  it "uses the configured replyto email" do
    expect(mail.reply_to).to eq(["replyto+#{proposal.public_id}@example.com"])
  end

  it "includes the appropriate headers for threading" do
    # headers only get added when the Mail is #deliver-ed
    mail.deliver_later

    %w(In-Reply-To References).each do |header|
      expect(mail[header].value).to eq("<proposal-#{proposal.id}@#{DEFAULT_URL_HOST}>")
    end
  end

  it "generates a multipart message (plain text and html)" do
    # http://stackoverflow.com/a/6934231
    expect(mail.body.parts.collect(&:content_type)).to match_array ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
  end
end
