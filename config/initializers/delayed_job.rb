# https://github.com/collectiveidea/delayed_job#gory-details

Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.logger = Logger.new(STDOUT)
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.raise_signal_exceptions = :term
