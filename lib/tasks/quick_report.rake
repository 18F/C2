namespace :quick_report do
  desc "Output a budget report overview"
  task budget: :environment do

  email = ENV['BUDGET_REPORT_RECIPIENT']
  ReportMailer.budget_status(email).deliver

  end
end
