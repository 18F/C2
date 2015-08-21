web: bin/rake cf:on_first_instance db:migrate && bundle exec puma
worker: bin/delayed_job run
clock: bundle exec clockwork config/clock.rb
