CANCEL_COMMENT = "This transaction has been cancelled in accordance with PBS NCR"\
                 " Director of Facilities Tim Turano's email on 6/30. 'The C2 system"\
                 " will be modified effective July 5th to eliminate the automatic"\
                 " routing to the CFO for micro purchases funded via B/A 60 and 61."\
                 " Any transaction in progress on this date and not yet approved by the"\
                 " CFO will be cancelled and need to be re-submitted by the requestor. '".freeze

def cancel(proposal:, with_comment:, and_user:)
  comments = "Request canceled with comments: " + with_comment
  proposal.cancel!
  proposal.comments.create!(comment_text: comments, user: and_user)
  DispatchFinder.run(proposal).deliver_cancelation_emails(and_user, params[:reason_input])
end

namespace :c2 do
  desc "Cancel pending NCR orders and send 2016-07-05 email"
  task cancel_pending: :environment do
    user = User.find_by!(email_address: "raphael.villas@gsa.gov")
    Proposal.where(client_data_type: "Ncr::WorkOrder")
            .where(status: "pending")
            .each { |p| cancel proposal: p, with_comment: CANCEL_COMMENT, and_user: user }
  end
end
