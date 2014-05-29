server '54.214.142.37', :app, :web, :primary => true
set :domain, '54.214.142.37'

role :app, domain
role :web, domain
role :db,  domain, :primary => true

