module Ncr
  module WorkOrdersHelper
    def approver_options
      # @todo should this list be limited by client/something else?
      # @todo is there a better order? maybe by current_user's use?
      User.order(:email_address).select(:email_address).map(&:email_address)
    end
  end
end
