module BrowserTimezoneRails
  module TimezoneControllerSetup
    private

    def time_zone_to_use
      if @current_user && @current_user.timezone.present?
        @current_user.timezone
      else
        browser_timezone.presence || Time.zone
      end
    end

    def set_time_zone(&action)
      Time.use_zone(time_zone_to_use, &action)
    end
  end
end
