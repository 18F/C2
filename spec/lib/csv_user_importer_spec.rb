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
      expect(Proposal).to receive(:client_slugs).and_return(['my_client']).twice

      @temp_file.write("First,Last,Email,Other\n")
      @temp_file.write("F1,L1,  EMAIL@EXAMPLE.COM  ,O1\n")
      @temp_file.write("SOME,Guy,some.guy@example.com,True")
      @temp_file.close
      importer = CsvUserImporter.new(@temp_file.path, "my_client")

      expect {
        importer.process_rows
      }.to change { User.count }.by(2)

      expect(User.exists?(
        first_name: 'F1',
        last_name: 'L1',
        email_address: 'email@example.com',
        client_slug: 'my_client'
      )).to eq(true)

      expect(User.exists?(
        first_name: 'Some',
        last_name: 'Guy',
        email_address: 'some.guy@example.com',
        client_slug: 'my_client'
      )).to eq(true)
    end

    it 'does not explode on an empty email field' do
      @temp_file.write("First,Last,Email,Other\n")
      @temp_file.write("F1,L1,    ,O1")
      @temp_file.close
      importer = CsvUserImporter.new(@temp_file.path, "my_client")
      expect(importer).to receive(:warn)

      expect {
        importer.process_rows
      }.to_not change { User.count }
    end
  end
end
