describe ClientDataCreator do
  include ActionDispatch::TestProcess

  describe "#run" do
    it "saves the model instance" do
      client_data_instance = build(:ncr_work_order)
      user = create(:user)

      expect {
        ClientDataCreator.new(client_data_instance, user).run
      }.to change { Ncr::WorkOrder.count }.from(0).to(1)
    end

    it "saves the proposal for the user passed in" do
      client_data_instance = build(:ncr_work_order, proposal: nil)
      user = create(:user)

      expect {
        ClientDataCreator.new(client_data_instance, user).run
      }.to change { user.proposals.count }.from(0).to(1)
    end

    it "saves the public_id for the proposal created" do
      client_data_instance = build(:ncr_work_order, proposal: nil)
      user = create(:user)

      client_data_creator = ClientDataCreator.new(client_data_instance, user)
      proposal = client_data_creator.run

      expect(proposal.public_id).not_to be_nil
    end

    it "creates attachments for the proposal if attachments present" do
      client_data_instance = build(:ncr_work_order, proposal: nil)
      user = create(:user)
      attachment_params = [
        fixture_file_upload('icon-user.png', 'image/png'),
        fixture_file_upload('icon-user.png', 'image/png'),
      ]

      expect {
        ClientDataCreator.new(client_data_instance, user, attachment_params).run
      }.to change { Attachment.count }.from(0).to(2)
    end

    it "does not error on missing attachments" do
      client_data_instance = build(:ncr_work_order, proposal: nil)
      user = create(:user)
      attachment_params = []

      expect {
        ClientDataCreator.new(client_data_instance, user, attachment_params).run
      }.not_to raise_error
    end
  end
end
