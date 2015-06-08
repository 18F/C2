def gsa18f_yaml_file(file_path)
  yaml = YAML.load_file(file_path)
  secret = yaml["private"] || {}
  find = lambda {|field_name|
    yaml.fetch(field_name,
               secret[field_name])
  }
  user = User.for_email(find["email"])
  user.update(
    first_name: find["first_name"],
    last_name: find["last_name"],
    client_slug: "gsa18f"
  )
end

namespace :import_users do
  desc "Import users from a 18f team"
  task team_yaml: :environment do
    dir = ENV['DIR']
    if !dir
      raise "DIR must be specified. e.g. rake import_users:team_yaml DIR=/path/to/data-private/team/"
    elsif !Dir.exists?(dir)
      raise "DIR (#{dir}) is not a directory"
    else
      if !dir.end_with?(File::SEPARATOR)
        dir = dir + File::SEPARATOR
      end

      Dir.glob(dir + "*.yml").each(&method(:gsa18f_yaml_file))
      Dir.glob(dir + "private" + File::SEPARATOR + "*.yml").each(&method(:gsa18f_yaml_file))
    end
  end

  task one: :environment do
    email = ENV['EMAIL']
    if !email
      raise 'EMAIL must be specified. e.g. rake import_users:one EMAIL=anna.smith@some.gov FIRST=Anna LAST=Smith CLIENT=gsa18f'
    end
    user = User.for_email(email)
    update = {}
    if !ENV['FIRST'].nil?
      update[:first_name] = ENV['FIRST']
    end
    if !ENV['LAST'].nil?
      update[:last_name] = ENV['LAST']
    end
    if !ENV['CLIENT'].nil?
      update[:client_slug] = ENV['CLIENT']
    end

    if update
      user.update(update)
    end
  end

  task csv: :environment do
    file, client = ENV['FILE'], ENV['CLIENT']
    if !file
      raise 'FILE must be specified. e.g. rake import_users:csv FILE=/path/to.csv CLIENT=gsa18f'
    elsif !client
      raise 'CLIENT must be specified. e.g. rake import_users:csv FILE=/path/to.csv CLIENT=gsa18f'
    end

    importer = CsvUserImporter(ENV['FILE'], ENV['CLIENT'])
    ['FIRST_NAME_COL', 'LAST_NAME_COL', 'EMAIL_COL'].each do |key|
      if ENV[key]
        assignment = key.downcase + "="
        importer.send(assignment, ENV[key])
      end
    end
    importer.process_rows()
  end
end
