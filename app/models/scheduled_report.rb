class ScheduledReport < ActiveRecord::Base
  enum frequency: { daily: 0, weekly: 1, monthly: 2, never: 3 }
  belongs_to :user
  belongs_to :report
end
