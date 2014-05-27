server '54.203.77.3', :app, :web, :primary => true
set :domain, '54.203.77.3'

role :app, domain
role :web, domain
role :db,  domain, :primary => true

