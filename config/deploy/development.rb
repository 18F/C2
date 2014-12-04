# development.rb | production.rb
server '54.245.235.114', :app, :web, :primary => true
set :domain, '54.245.235.114'

role :app, domain
role :web, domain
role :db,  domain, :primary => true

