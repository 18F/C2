web: bin/rake cf:on_first_instance db:migrate && bundle exec puma
worker: bundle exec clockwork config/clock.rb
