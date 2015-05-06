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
      puts "DIR must be specified. e.g. rake import_users:team_yaml DIR=/path/to/data-private/team/"
    elsif !Dir.exists?(dir)
      puts "DIR (#{dir}) is not a directory"
    else
      if !dir.end_with?(File::SEPARATOR)
        dir = dir + File::SEPARATOR
      end

      Dir.glob(dir + "*.yml").each(&method(:gsa18f_yaml_file))
      Dir.glob(dir + "private" + File::SEPARATOR + "*.yml").each(&method(:gsa18f_yaml_file))
    end
  end
end
