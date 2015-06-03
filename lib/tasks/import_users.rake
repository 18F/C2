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

    data = CSV.read(ENV['FILE'], headers: true)
    headers = data.headers()
    first_col = ENV['FIRST_NAME_COL'] || headers.find {|header| header.downcase.include? "first"}
    last_col = ENV['LAST_NAME_COL'] || headers.find {|header| header.downcase.include? "last"}
    email_col = ENV['EMAIL_COL'] || headers.find {|header| header.downcase.include? "email"}
    if !first_col || !last_col || !email_col
      raise "Couldn't determine one or more of first name, last name, email: #{headers}"
    end

    data.each do |row|
      email = row[email_col]
      if !email
        warn "Email is empty: " + row.inspect
      else
        User.for_email(email.strip).update(
          first_name: (row[first_col] || "").titleize,
          last_name: (row[last_col] || "").titleize,
          client_slug: ENV['CLIENT']
        )
      end
    end
  end
end
