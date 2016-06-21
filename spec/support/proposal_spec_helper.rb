module ProposalSpecHelper
  def linear_approval_statuses(proposal)
    proposal.individual_steps.pluck(:status)
  end

  def fully_complete(proposal, completer = nil)
    proposal.individual_steps.each do |step|
      step.reload
      step.complete!
      step.update(completer: completer) if completer
    end
  end
end
