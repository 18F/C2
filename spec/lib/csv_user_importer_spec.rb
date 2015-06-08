describe CsvUserImporter do
  around (:each) do |test|
    @temp_file = Tempfile.new("temp_file.csv")
    test.run
    @temp_file.close unless @temp_file.closed?
    @temp_file.unlink
  end

  describe 'header guessing' do
    it 'makes reasonable guesses when column names are sensical' do
      @temp_file.write("Col1,Some First,Col3,Last Name,And Then Email\n")
      @temp_file.write("v1,v2,v3,v4,v5")
      @temp_file.close
      importer = CsvUserImporter.new(@temp_file.path, "client")
      expect(importer.first_name_col).to eq('Some First')
      expect(importer.last_name_col).to eq('Last Name')
      expect(importer.email_col).to eq('And Then Email')
    end

    it "doesn't explode if the column names can't be determined" do
      @temp_file.write("A Column,Another,A Third,And A Final\n")
      @temp_file.write("v1,v2,v3,v4")
      @temp_file.close
      importer = CsvUserImporter.new(@temp_file.path, "client")
      expect(importer.first_name_col).to be_nil
      expect(importer.last_name_col).to be_nil
      expect(importer.email_col).to be_nil
    end
  end

  describe '#process_rows' do
    it 'creates the appropriate users' do
      @temp_file.write("First,Last,Email,Other\n")
      @temp_file.write("F1,L1,  E1  ,O1\n")
      @temp_file.write("SOME,Guy,some.guy@gov.gov,True")
      @temp_file.close
      importer = CsvUserImporter.new(@temp_file.path, "my_client")
      importer.process_rows
      users = User.order('id')
      expect(users.count).to be(2)
      user1, user2 = users
      expect(user1.first_name).to eq('F1')
      expect(user1.last_name).to eq('L1')
      expect(user1.email_address).to eq('e1')
      expect(user1.client_slug).to eq('my_client')
      expect(user2.first_name).to eq('Some')
      expect(user2.last_name).to eq('Guy')
      expect(user2.email_address).to eq('some.guy@gov.gov')
      expect(user2.client_slug).to eq('my_client')
    end

    it 'does not explode on an empty email field' do
      @temp_file.write("First,Last,Email,Other\n")
      @temp_file.write("F1,L1,    ,O1")
      @temp_file.close
      importer = CsvUserImporter.new(@temp_file.path, "my_client")
      expect(importer).to receive(:warn)
      importer.process_rows
      expect(User.count).to be(0)
    end
  end
end
