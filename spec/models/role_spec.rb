describe Role do

  let(:role) { build(:role) }

  context 'valid attributes' do
    it "is valid" do
      expect(role).to be_valid
    end
  end

end
