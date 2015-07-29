namespace :quick_report do
  desc "Output a budget report overview"
  task budget: :environment do
    puts "SENDING BUDGET REPORT..."
    email = ENV['BUDGET_REPORT_RECIPIENT']
    ReportMailer.budget_status(email).deliver
    puts "...DONE"
  end
end
