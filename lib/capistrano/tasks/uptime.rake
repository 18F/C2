# https://github.com/capistrano/capistrano/blob/master/README.md#tasks
desc "Report Uptimes"
task :uptime do
  on roles(:all) do |host|
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end
