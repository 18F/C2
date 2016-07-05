CANCEL_COMMENT = "This transaction has been cancelled in accordance with PBS NCR"\
                 " Director of Facilities Tim Turano's email on 6/30. 'The C2 system"\
                 " will be modified effective July 5th to eliminate the automatic"\
                 " routing to the CFO for micro purchases funded via B/A 60 and 61."\
                 " Any transaction in progress on this date and not yet approved by the"\
                 " CFO will be cancelled and need to be re-submitted by the requestor. '".freeze

def cancel(proposal:, with_comment:)
  comments = "Request canceled with comments: " + with_comment
  proposal.cancel!
  proposal.comments.create!(comment_text: comments, user: current_user)
  DispatchFinder.run(proposal).deliver_cancelation_emails(current_user, params[:reason_input])
end

namespace :c2 do
  desc "Cancel pending NCR orders and send 2016-07-05 email"
  task cancel_pending: :environment do
    Proposal.where(client_data_type: "Ncr::WorkOrder")
            .where(status: "pending")
            .each { |p| cancel proposal: p, with_comment: CANCEL_COMMENT }
  end
end
