server '54.185.133.124', :app, :web, :primary => true
set :domain, '54.185.133.124'

role :app, domain
role :web, domain
role :db,  domain, :primary => true
