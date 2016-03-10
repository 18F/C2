class ScheduledReporter
  attr_reader :check_time

  def initialize(check_time)
    unless check_time.is_a?(Time)
      raise ArgumentError, "check_time must be a Time object"
    end
    @check_time = check_time
  end

  def run
    if check_time.day == 1
      send_monthlies
    end
    if check_time.monday?
      send_weeklies
    end
    send_dailies
  end

  private

  def send_monthlies
    ScheduledReport.find_in_batches do |scheduled_reports|
      scheduled_reports.each do |scheduled_report|
        if scheduled_report.monthly?
          send_report(scheduled_report)
        end
      end
    end
  end

  def send_weeklies
    ScheduledReport.find_in_batches do |scheduled_reports|
      scheduled_reports.each do |scheduled_report|
        if scheduled_report.weekly?
          send_report(scheduled_report)
        end
      end
    end
  end

  def send_dailies
    ScheduledReport.find_in_batches do |scheduled_reports|
      scheduled_reports.each do |scheduled_report|
        if scheduled_report.daily?
          send_report(scheduled_report)
        end
      end
    end
  end

  def send_report(scheduled_report)
    ReportMailer.scheduled_report(scheduled_report.name, scheduled_report.report, scheduled_report.user).deliver_later
  end
end
