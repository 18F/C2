shared_examples "a proposal email" do
  include EnvVarSpecHelper

  it "uses the configured sender email" do
    with_env_vars(
      "NOTIFICATION_FROM_EMAIL" => "reply@example.com",
      "NOTIFICATION_REPLY_TO" => "replyto@example.com"
    ) do
      expect(mail.from).to eq(["reply@example.com"])
    end
  end

  it "uses the configured replyto email" do
    with_env_vars(
      "NOTIFICATION_FROM_EMAIL" => "reply@example.com",
      "NOTIFICATION_REPLY_TO" => "replyto@example.com"
    ) do
      expect(mail.reply_to).to eq(["replyto+#{proposal.public_id}@example.com"])
    end
  end

  it "includes the appropriate headers for threading" do
    # headers only get added when the Mail is #deliver-ed
    mail.deliver_later

    %w(In-Reply-To References).each do |header|
      expect(mail[header].value).to eq("<proposal-#{proposal.id}@#{ENV['DEFAULT_URL_HOST']}>")
    end
  end

  it "generates a multipart message (plain text and html)" do
    # http://stackoverflow.com/a/6934231
    expect(mail.body.parts.collect(&:content_type)).to match_array ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
  end
end
