def read_fixture(filename)
  path = File.expand_path("../../fixtures/#{filename}.json", __FILE__)
  File.read(path)
end
