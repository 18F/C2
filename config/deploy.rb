require "bundler/capistrano"
require "rvm/capistrano"

set :application, "c2"
set :repository,  "https://github.com/18F/C2.git"
set :branch, :master
set :domain, '54.185.133.124'
set :deploy_to, "/var/www/#{application}"
set :user, "ubuntu"
set :rvm_type, :user
set :keep_releases, 6
set :rvm_ruby_string, "2.1.1"
set :scm, :git
set :use_sudo, true

default_run_options[:pty] = true

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Add config dir to shared folder"
  task :add_shared_config do
    run "mkdir #{deploy_to}/shared/config"
  end

  desc "Symlink configs"
  task :symlink_configs, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/*.yml #{release_path}/config/"
  end
end

after 'bundle:install', 'deploy:symlink_configs'
after 'deploy:setup', 'deploy:add_shared_config'