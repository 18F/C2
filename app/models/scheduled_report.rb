class ScheduledReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  def monthly?
    frequency == "monthly"
  end

  def weekly?
    frequency == "weekly"
  end

  def daily?
    frequency == "daily"
  end
end
