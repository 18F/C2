class ClientDataCreator
  def initialize(client_data, user, attachment_data = [])
    @client_data = client_data
    @user = user
    @attachment_data = attachment_data
  end

  def run
    client_data.build_proposal(requester: user)
    client_data.save
    create_attachments
    add_public_id
    proposal
  end

  private

  attr_reader :client_data, :user, :attachment_data

  def create_attachments
    attachment_data.each do |file|
      proposal.attachments.create(user: user, file: file)
    end
  end

  def add_public_id
    proposal.update(public_id: public_id)
  end

  def public_id
    client_data.public_identifier
  end

  def proposal
    @proposal ||= client_data.proposal
  end
end
