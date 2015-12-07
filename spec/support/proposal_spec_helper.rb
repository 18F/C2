module ProposalSpecHelper
  def linear_approval_statuses(proposal)
    proposal.individual_steps.pluck(:status)
  end

  def fully_approve(proposal, completer = nil)
    proposal.individual_steps.each do |step|
      step.reload
      step.approve!
      if completer
        step.update(completer: completer)
      end
    end
  end
end
