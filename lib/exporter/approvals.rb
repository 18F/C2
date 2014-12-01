module Exporter
  class Approvals < Exporter::Base
    def headers
      ["status","approver","created_at"]
    end

    def approvals
      self.cart.approvals
    end

    def rows
      self.approvals.map do |approval|
        [approval.status, approval.user.email_address,approval.updated_at]
      end
    end
  end
end
