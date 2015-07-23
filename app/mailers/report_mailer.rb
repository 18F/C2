class ReportMailer < ActionMailer::Base

  def budget_status(to_email='raphael.villas@gsa.gov', proposal=Proposal.last)
    @proposal = proposal
    headers['In-Reply-To'] = @proposal.email_msg_id
    headers['References'] = @proposal.email_msg_id

    mail(
      to: to_email,
      subject: "Daily budget report for #{Time.now.strftime("%a %m/%d/%y")}",
      from: 'communicart.sender@gsa.gov',
      template_name: 'budget_report_email'
    )

  end

end