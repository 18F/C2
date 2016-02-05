module Ncr
  class LastWeekCountQuery
    def find
      Ncr::WorkOrder.where("created_at > ?", 1.week.ago).count
    end
  end
end
